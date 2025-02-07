//
//  CalendarDateRangePickerViewController.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

public protocol CalendarDateRangePickerViewControllerDelegate {
    func didTapLeftBarButton(startDate: Date?, endDate: Date?)
    func didTapRightBarButton(startDate: Date?, endDate: Date?)
    func didSelectStartDate(startDate: Date?)
    func didSelectEndDate(endDate: Date?)
}

public class CalendarDateRangePickerViewController: UICollectionViewController {
    
    @objc let cellReuseIdentifier = "CalendarDateRangePickerCell"
    @objc let headerReuseIdentifier = "CalendarDateRangePickerHeaderView"
    
    public var delegate: CalendarDateRangePickerViewControllerDelegate!
    
    @objc let itemsPerRow = 7
    @objc let itemHeight: CGFloat = 40
    @objc let collectionViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    @objc public var minimumDate: Date!
    @objc public var maximumDate: Date!
    
    @objc public var selectedStartDate: Date?
    @objc public var selectedEndDate: Date?
    @objc var selectedStartCell: IndexPath?
    @objc var selectedEndCell: IndexPath?
    
    @objc public var disabledDates: [Date]?
    
    @objc public var cellHighlightedColor = UIColor(white: 0.9, alpha: 1.0)
    @objc public static let defaultCellFontSize:CGFloat = 15.0
    @objc public static let defaultHeaderFontSize:CGFloat = 17.0
    @objc public var cellFont:UIFont = UIFont(name: "HelveticaNeue", size: CalendarDateRangePickerViewController.defaultCellFontSize)!
    @objc public var headerFont:UIFont = UIFont(name: "HelveticaNeue-Light", size: CalendarDateRangePickerViewController.defaultHeaderFontSize)!

    @objc public var selectedColor = UIColor(red: 66/255.0, green: 150/255.0, blue: 240/255.0, alpha: 1.0)
    @objc public var selectedLabelColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    @objc public var highlightedLabelColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    @objc public var titleText = "Select Dates"
    @objc public var leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(CalendarDateRangePickerViewController.didTapLeftBarButton))
    @objc public var rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(CalendarDateRangePickerViewController.didTapRightBarButton))
    @objc public var saturdayColor = UIColor.blue
    @objc public var sundayColor = UIColor.red
    @objc public var maxSelectableRange = 30

    @objc let calendar = Calendar(identifier: .gregorian)
    @objc public var dateFormatterLocale = Locale(identifier: "en_US_POSIX")

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.titleText
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = UIColor.white

        collectionView?.register(CalendarDateRangePickerCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView?.register(CalendarDateRangePickerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView?.contentInset = collectionViewInsets
        
        if minimumDate == nil {
            minimumDate = Date()
        }
        if maximumDate == nil {
            maximumDate = calendar.date(byAdding: .year, value: 3, to: minimumDate)
        }

        self.leftBarButtonItem.target = self
        self.leftBarButtonItem.action = #selector(CalendarDateRangePickerViewController.didTapLeftBarButton)
        self.navigationItem.leftBarButtonItem = self.leftBarButtonItem
        self.rightBarButtonItem.target = self
        self.rightBarButtonItem.action = #selector(CalendarDateRangePickerViewController.didTapRightBarButton)
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem

        if let newIndexPath = getIndexPathFromDate(date: selectedStartDate ?? Date()) {
            collectionView?.layoutIfNeeded()
            collectionView?.scrollToItem(at: newIndexPath, at: .centeredVertically, animated: false)
        }
    }
    
    @objc func didTapLeftBarButton() {
        delegate.didTapLeftBarButton(startDate: selectedStartDate, endDate: selectedEndDate)
    }
    
    @objc func didTapRightBarButton() {
        delegate.didTapRightBarButton(startDate: selectedStartDate, endDate: selectedEndDate)
    }
}

extension CalendarDateRangePickerViewController {
    
    // UICollectionViewDataSource
    
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getDifferenceOfMonth(from: minimumDate, to: maximumDate) + 1
    }

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let firstDateForSection = getFirstDateForSection(section: section)
        let weekdayRowItems = 7
        let blankItems = getWeekday(date: firstDateForSection) - 1
        let daysInMonth = getNumberOfDaysInMonth(date: firstDateForSection)
        return weekdayRowItems + blankItems + daysInMonth
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarDateRangePickerCell
        
        cell.highlightedColor = self.cellHighlightedColor
        cell.selectedColor = self.selectedColor
        cell.selectedLabelColor = self.selectedLabelColor
        cell.highlightedLabelColor = self.highlightedLabelColor
        cell.font = self.cellFont
        cell.reset()
        let blankItems = getWeekday(date: getFirstDateForSection(section: indexPath.section)) - 1
        if indexPath.item == 0 || (indexPath.item % 7) == 0 {
            cell.label.textColor = self.sundayColor
        } else if (indexPath.item % 7) == 6 {
            cell.label.textColor = self.saturdayColor
        }
        if indexPath.item < 7 {
            cell.label.text = getWeekdayLabel(weekday: indexPath.item + 1)
        } else if indexPath.item < 7 + blankItems {
            cell.label.text = ""
        } else {
            let dayOfMonth = indexPath.item - (7 + blankItems) + 1
            let date = getDate(dayOfMonth: dayOfMonth, section: indexPath.section)
            cell.date = date
            cell.label.text = "\(dayOfMonth)"

            if disabledDates != nil {
                if (disabledDates?.contains(cell.date!))! {
                    cell.disable()
                }
            }
            if isBefore(dateA: date, dateB: minimumDate) {
                cell.disable()
            }
            if isAfter(dateA: date, dateB: maximumDate) {
                cell.disable()
            }
            if selectedStartDate != nil && selectedEndDate != nil && isBefore(dateA: selectedStartDate!, dateB: date) && isBefore(dateA: date, dateB: selectedEndDate!) {
                // Cell falls within selected range
                if dayOfMonth == 1 {
                    cell.highlightRight()
                } else if dayOfMonth == getNumberOfDaysInMonth(date: date) {
                    cell.highlightLeft()
                } else {
                    cell.highlight()
                }
            } else if selectedStartDate != nil && areSameDay(dateA: date, dateB: selectedStartDate!) {
                // Cell is selected start date
                cell.select()
                if selectedEndDate != nil {
                    cell.highlightRight()
                }
            } else if selectedEndDate != nil && areSameDay(dateA: date, dateB: selectedEndDate!) {
                cell.select()
                cell.highlightLeft()
            }
        }
        return cell
    }
    
    override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! CalendarDateRangePickerHeaderView
            headerView.label.text = getMonthLabel(date: getFirstDateForSection(section: indexPath.section))
            headerView.font = headerFont
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }
}

extension CalendarDateRangePickerViewController: UICollectionViewDelegateFlowLayout {
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarDateRangePickerCell
        guard let cellDate = cell.date else { return }
        if isBefore(dateA: cellDate, dateB: minimumDate) {
            return
        }
        if isAfter(dateA: cellDate, dateB: maximumDate) {
            return
        }

        if let disabledDates = disabledDates {
            if (disabledDates.contains(cellDate)) {
                return
            }
        }
        if indexPath.item < 7 {
            // day of the week cannot select
            return
        }
        if cell.label.text?.isEmpty ?? true {
            // empty cell cannot select
            return
        }

        if selectedStartDate == nil {
            selectedStartDate = cellDate
            selectedStartCell = indexPath
            delegate.didSelectStartDate(startDate: selectedStartDate)
        } else if selectedEndDate == nil {
            if selectedStartCell == nil {
                selectedStartCell = getIndexPathFromDate(date: selectedStartDate!)
            }
            if isBefore(dateA: selectedStartDate!, dateB: cellDate) && !isBetween(selectedStartCell!, and: indexPath) {
                if (getDifferenceOfDay(from: selectedStartDate!, to: cellDate) + 1) > maxSelectableRange, let newIndexPath = getIndexPathFromDate(date: getMaxSelectableDate() ?? Date()) {
                    // If out of the selection range, select the end point of the selection range
                    selectedEndDate = calendar.date(byAdding: .day, value: maxSelectableRange - 1, to: selectedStartDate ?? Date()) ?? Date()
                    collectionView.scrollToItem(at: newIndexPath, at: .centeredVertically, animated: true)
                } else {
                    selectedEndDate = cellDate
                }
                delegate.didSelectEndDate(endDate: selectedEndDate)
            } else {
                // If a cell before the currently selected start date is selected then just set it as the new start date
                selectedStartDate = cellDate
                selectedStartCell = indexPath
                delegate.didSelectStartDate(startDate: selectedStartDate)
            }
        } else {
            selectedStartDate = cellDate
            selectedStartCell = indexPath
            delegate.didSelectStartDate(startDate: selectedStartDate)
            selectedEndDate = nil
        }
        collectionView.reloadData()
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = collectionViewInsets.left + collectionViewInsets.right
        let availableWidth = view.frame.width - padding
        let itemWidth = availableWidth / CGFloat(itemsPerRow)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 50)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension CalendarDateRangePickerViewController {
    
    // Helper functions
    
    @objc func getFirstDate() -> Date {
        var components = calendar.dateComponents([.month, .year], from: minimumDate)
        components.day = 1
        return calendar.date(from: components)!
    }
    
    @objc func getFirstDateForSection(section: Int) -> Date {
        return calendar.date(byAdding: .month, value: section, to: getFirstDate())!
    }
    
    @objc func getMonthLabel(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = dateFormatterLocale
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    @objc func getWeekdayLabel(weekday: Int) -> String {
        var components = DateComponents()
        components.calendar = calendar
        components.weekday = weekday
        let date = calendar.nextDate(after: Date(), matching: components, matchingPolicy: Calendar.MatchingPolicy.strict)
        if date == nil {
            return "E"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = dateFormatterLocale
        dateFormatter.dateFormat = "EEEEE"
        return dateFormatter.string(from: date!)
    }
    
    @objc func getWeekday(date: Date) -> Int {
        return calendar.dateComponents([.weekday], from: date).weekday!
    }
    
    @objc func getNumberOfDaysInMonth(date: Date) -> Int {
        return calendar.range(of: .day, in: .month, for: date)!.count
    }
    
    @objc func getDate(dayOfMonth: Int, section: Int) -> Date {
        var components = calendar.dateComponents([.month, .year], from: getFirstDateForSection(section: section))
        components.day = dayOfMonth
        return calendar.date(from: components)!
    }
    
    @objc func areSameDay(dateA: Date, dateB: Date) -> Bool {
        return calendar.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedSame
    }
    
    @objc func isBefore(dateA: Date, dateB: Date) -> Bool {
        return calendar.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedAscending
    }

    @objc func isAfter(dateA: Date, dateB: Date) -> Bool {
        return calendar.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedDescending
    }
    
    @objc func isBetween(_ startDateCellIndex: IndexPath, and endDateCellIndex: IndexPath) -> Bool {
        
        if disabledDates == nil{
            return false
        }
        
        var index = startDateCellIndex.row
        var section = startDateCellIndex.section
        var currentIndexPath: IndexPath
        var cell: CalendarDateRangePickerCell?

        while !(index == endDateCellIndex.row && section == endDateCellIndex.section) {
            currentIndexPath = IndexPath(row: index, section: section)
            cell = collectionView?.cellForItem(at: currentIndexPath) as? CalendarDateRangePickerCell
            if cell?.date == nil{
                section = section + 1
                let blankItems = getWeekday(date: getFirstDateForSection(section: section)) - 1
                index = 7 + blankItems
                currentIndexPath = IndexPath(row: index, section: section)
                cell = collectionView?.cellForItem(at: currentIndexPath) as? CalendarDateRangePickerCell
            }
            
            if cell != nil && (disabledDates?.contains((cell!.date)!))! {
                return true
            }
            index = index + 1
        }
        
        return false
    }

    @objc func getDifferenceOfDay(from: Date, to: Date) -> Int {
        let fromDayComponents = calendar.dateComponents([.year, .month, .day], from: from)
        let fromDay = calendar.date(from: fromDayComponents)

        let toDayComponents = calendar.dateComponents([.year, .month, .day], from: to)
        let toDay = calendar.date(from: toDayComponents)

        let difference = calendar.dateComponents([.day], from: fromDay ?? from, to: toDay ?? to)

        return difference.day ?? 0
    }

    @objc func getDifferenceOfMonth(from: Date, to: Date) -> Int {
        var firstDayComponents = calendar.dateComponents([.year, .month, .day], from: from)
        firstDayComponents.day = 1
        let minimumMonthFirstDate = calendar.date(from: firstDayComponents)

        var lastDayComponents = calendar.dateComponents([.year, .month, .day], from: to)
        lastDayComponents.day = getNumberOfDaysInMonth(date: to)
        let maximumMonthLastDate = calendar.date(from: lastDayComponents)

        let difference = calendar.dateComponents([.month], from: minimumMonthFirstDate ?? from, to: maximumMonthLastDate ?? to)

        return difference.month ?? 0
    }

    @objc func getMaxSelectableDate() -> Date? {
        guard let selectedStartDate = selectedStartDate else { return nil }
        let maxSelectableDate = calendar.date(byAdding: .day, value: maxSelectableRange - 1, to: selectedStartDate)
        return maxSelectableDate
    }

    @objc func getIndexPathFromDate(date: Date) -> IndexPath? {
        guard let selectedStartDate = selectedStartDate else { return nil }
        let diff = getDifferenceOfMonth(from: selectedStartDate, to: date)
        let selectedStartDateSection = getDifferenceOfMonth(from: minimumDate, to: selectedStartDate)
        let section = selectedStartDateSection + diff
        let firstDateForSection = getFirstDateForSection(section: section)
        let weekdayRowItems = 7
        let blankItems = getWeekday(date: firstDateForSection) - 1
        let day = calendar.dateComponents([.day], from: date).day ?? 0
        let itemOfSection = (weekdayRowItems - 1) + blankItems + day
        let indexPath = IndexPath(item: itemOfSection, section: section)
        return indexPath
    }
}
