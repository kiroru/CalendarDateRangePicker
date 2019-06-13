# CalendarDateRangePickerViewController

[![Version](https://img.shields.io/cocoapods/v/CalendarDateRangePickerViewController.svg?style=flat)](http://cocoapods.org/pods/CalendarDateRangePicker)
[![License](https://img.shields.io/cocoapods/l/CalendarDateRangePickerViewController.svg?style=flat)](http://cocoapods.org/pods/CalendarDateRangePicker)
[![Platform](https://img.shields.io/cocoapods/p/CalendarDateRangePickerViewController.svg?style=flat)](http://cocoapods.org/pods/CalendarDateRangePicker)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Here's what it looks like:

![alt text](https://github.com/Ljuka/CalendarDateRangePickerViewController/blob/master/recording.gif "Select start and end dates easily.")

## Usage

It's as simple as:

```swift
let dateRangePickerViewController = CalendarDateRangePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
dateRangePickerViewController.delegate = self
let navigationController = UINavigationController(rootViewController: dateRangePickerViewController)
self.navigationController?.present(navigationController, animated: true, completion: nil)
```

Just implement the delegate methods:

```swift
protocol CalendarDateRangePickerViewControllerDelegate {
    func didTapLeftBarButton(startDate: Date?, endDate: Date?)
    func didTapRightBarButton(startDate: Date?, endDate: Date?)
    func didSelectStartDate(startDate: Date?)
    func didSelectEndDate(endDate: Date?)
}
```

You can also set additional options to override the defaults:

```swift
dateRangePickerViewController.minimumDate = Date()
dateRangePickerViewController.maximumDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())
dateRangePickerViewController.selectedStartDate = Date()
dateRangePickerViewController.selectedEndDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())
dateRangePickerViewController.selectedColor = UIColor.red
dateRangePickerViewController.titleText = "Select Date Range"
```

## Installation

CalendarDateRangePickerViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CalendarDateRangePicker', :git => 'https://github.com/kiroru/CalendarDateRangePicker.git', :branch => 'fork_release'
```

## Author

Ljuka, ljubom94@gmail.com
aoki, aoki.sho@kiroru-inc.jp

## License

CalendarDateRangePickerViewController is available under the MIT license. See the LICENSE file for more info.
