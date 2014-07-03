# Appium iOS Driver: UIAutomation for Appium

Appium iOS Driver is an alternative Ruby library for use with [Appium](http://appium.io) and is aimed specifically at the iOS platform (Appium itself supports multiple platforms).

Rather than using XPaths or other element selector mechanisms, this library allows you to write automated test scripts using a Ruby mirror of the [official Apple UIAutomation API](https://developer.apple.com/library/ios/documentation/DeveloperTools/Reference/UIAutomationRef/_index.html).

Given the following example from the UIAutomation documentaiton:

```javascript
var target = UIATarget.localTarget();
var app = target.frontMostApp();
var tabBar = app.mainWindow().tabBar();
var destinationScreen = "Recipes";
if (tabBar.selectedButton().name() != destinationScreen) {
    tabBar.buttons()[destinationScreen].tap();
}
```

The same could be written in Ruby:

```ruby
driver = ...
target = driver.target
app = target.front_most_app
tab_bar = app.main_window.tab_bar
destination_screen = 'Recipes'
if tab_bar.selected_button.name != destination_screen 
  tab_bar.buttons[destination_screen].tap
end
```
