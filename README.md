# Rubium: iOS Automation using Ruby and Appium

[![Build Status](http://img.shields.io/travis/songkick/rubium-ios.svg?style=flat)](https://travis-ci.org/songkick/rubium-ios)
[![Code Climate](http://img.shields.io/codeclimate/github/songkick/rubium-ios.svg?style=flat)](https://codeclimate.com/github/songkick/rubium-ios)
[![Coverage Status](http://img.shields.io/coveralls/songkick/rubium-ios.svg?style=flat)](https://coveralls.io/r/songkick/rubium-ios)

```
gem install rubium-ios
```

[API documentation (master)](http://rubydoc.info/github/songkick/rubium-ios/master/frames)

## Introduction

Rubium is an alternative Ruby library for use with [Appium](http://appium.io) and is aimed specifically at the iOS platform (Appium itself supports multiple platforms).

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
target = driver.target
app = target.front_most_app
tab_bar = app.main_window.tab_bar
destination_screen = 'Recipes'
if tab_bar.selected_button.name != destination_screen 
  tab_bar.buttons[destination_screen].tap
end
```

The above example could be written using identical method names to the Javascript version (using lowerCamelCase naming) however it has been written using underscore_case as this is normal Ruby style - the method names are converted to their lowerCamelCase equivalent automatically.

This means if you know how to use UIAutomation, you know how to use this library.

## Using Rubium in depth

Before you get started, you need a compiled version of your app and the Appium server running. Setting up Appium is outside the scope of this tutorial but you can follow the [Appium Getting Started guide](http://appium.io/getting-started.html?lang=en) to get you up and running. The quickest way to get up and running is to download the Appium.app self-contained bundle.

You also need to compile your app (for the simulator in this example) and put the .app bundle in a known location. You can compile your app to a known location using `xcodebuild <options> install DSTROOT=<path/to/put/app>`. You'll need to know this location to set up the iOS driver.
  
### Creating a driver

Appium implements the Selenium web driver protocol and this library is built on top of the Ruby Selenium::WebDriver client, but it abstracts most of those details away from you.

The `Rubium::Driver` class is the class that lets you launch and terminate a remote Instruments session (which will trigger your app to launch automatically). It also lets you configure things like timeouts and provides some lower level methods for finding elements using an xpath, executing Javascript directly and capturing screenshots. It also provides access to `UIAutomation::Target` which represents the `UIATarget` object in the Javascript API and is the root of the entire UIAutomation API.

To initialise an instance of `Rubium::Driver`, you need to pass it the desired capabilities for your app. You can also pass in a hostname and port if you are running Appium on another machine or on a non-standard port.

Capabilities define the behaviour of your session and tell Appium things like the path to your app, it's bundle ID and if you're running on a real device, the device UDID. A full list of capabilities can be viewed in the [Appium documentation](https://github.com/appium/appium/blob/master/docs/en/caps.md). 

You can use the classes in `Rubium::Capabilities` to create your driver capabilities. There are certain keys that are required, however most keys have sensible defaults so most of the time the minimum you will need to specify are the path to your app and your app's bundle ID.

```ruby
capabilities = Rubium::Capabilities::Simulator.new do |caps|
  caps.app = '/path/to/my/App.app'
  caps.bundle_id = 'com.example.MyApp'
end
```

If you want to test on a real device, you'll need to provide a path to an IPA file instead of a .app bundle (see Testing On a Real Device):

```ruby
capabilities = Rubium::Capabilities::Device.new do |caps|
  caps.app = '/path/to/my/App.ipa'
  caps.bundle_id = 'com.example.MyApp'
  caps.udid = 'YOUR_DEVICE_UDID'
end
```

You can now use these capabilities to create a driver:

```ruby
driver = Rubium::Driver.new(capabilities)
```

### Launching a session

Once you have created your driver, you can start a new session by calling `launch`:

```ruby
driver.launch # will start Instruments and launch your app on the simulator or device
```

And when you are finished you can quit the session:

```ruby
driver.quit # will quit the simulator and terminate Instruments
```

There is also a convenience method, `with_session` which takes a block. It will launch a session, call your block and then quit automatically:

```ruby
driver.with_session do
  # perform your test script here
end
```

### Interacting with the UIAutomation API

One of the core features of Appium is its ability to act as a bridge to the Instruments runtime which allows you to sent Javascript to be executed from your script. The driver method, `execute`, lets you do just that:

```ruby
driver.execute("UIATarget.localTarget().frontMostApp().mainWindow().tabBar().buttons[0].tap()")
```

However, this would be quite cumbersome, which is why the UIAutomation proxy API allows you to write your tests in Ruby using the same API and this code will be automatically transformed into the equivalent Javascript API and executed.

Instead of the above, you can write:

```ruby
driver.target.front_most_app.main_window.tab_bar.buttons[0].tap
```

If the Javascript API supports it, so does the Ruby API.

### A more detailed look at the UIAutomation API

Your entry point into this API is the driver method `target`, which returns an instance of `UIAutomation::Target`, which is in turn a sub-class of `UIAutomation::RemoteProxy`. All objects that act as proxies to an object in the Javascript API are sub-classes of `UIAutomation::RemoteProxy`.

To give you an idea of how `UIAutomation::RemoteProxy` works, here is a quick overview of some of its lower-level methods. 

All proxies return their Javascript equivalent from the `#to_javascript` method:

```ruby
driver.target.front_most_app.to_javascript # => UIATarget.localTarget().frontMostApp()
```

If the remote Javascript object has any interesting properties, you can get the property value using the `fetch` method:

```ruby
driver.target.fetch(:someProperty) # => property value
```

Alternatively you can use `[]` syntax to fetch a property value:

```ruby
driver.target[:someProperty]
```

If you want to perform a method on the object, you could use the `perform` method:

```ruby
driver.target.perform(:pushTimeout, 10) # => calls UIATarget.localTarget().pushTimeout(10)
```

However, instead of having to call `perform` all the time, you can just call the method directly on the proxy and it will call `perform` for you:

```ruby
driver.target.push_timeout(10)
```

As previously noted, you can use under_score_case and it will automatically be translated into lowerCamelCase.

The `perform` method can be used for any Javascript method that returns a primitive value such as a string, but if the method returns another object, all you would get is an empty `{}` which is the value Appium returns for Javascript objects, which isn't of much use.

Instead, you need a new proxy to that object. Instead of using `perform`, you would use `proxy_for`:

```ruby
driver.target.proxy_for(:frontMostApp) # => <RemoteProxy: UIATarget.localTarget().frontMostApp()>
```

There are two more methods that are similar to `proxy_for`: `element_proxy_for` and `element_array_proxy` for. Both of these methods return a `UIAutomation::Element` (or specific sub-class) or `UIAutomation::ElementArray` respectively. Both of these are equivalent to `UIAElement` and `UIAElementArray` in the Javascript API and both are sub-classes of `UIAutomation::RemoteProxy`. In addition, they both have a `parent` and `window` attribute that makes it easier to navigate through the view hierarchy. 

Even calling these methods would be cumbersome which is why out of the box, each `UIAutomation::RemoteProxy` sub-class defines convenience methods that return proxies for you without you having to call the lower-level proxy methods directly.

### Handling timeouts

There are a number of ways in which your test scripts could timeout when working with Appium and various ways of handling these timeouts.

### Session timeout

This occurs when there is a timeout communicating with the Appium server at the HTTP level, typically when you launch a session. This timeout affects all Selenium::WebDriver HTTP requests to the Appium server. The default value is 30 seconds.

You can specify a custom session timeout when you launch a session:

```ruby
# use a 60 second session timeout instead
driver = Rubium::Driver.new(capabilities)
driver.launch(60)
```

### Command timeout

The command timeout is the length of time Appium will wait to receive a new command from your script. If it doesn't receive any commands within this time, it will timeout and the current session will be terminated (causing the simulator to be killed).

The default value is 30 seconds, which should be plenty of time for most test scripts. One example of where you might want to set this to a higher value is if you are using an interactive console to debug your tests. You set the command timeout as part of your driver's capabilities using the `new_command_timeout` attribute:

```ruby
capabilities = Rubium::Capabilities::Simulator.new
capabilities.new_command_timeout = 100
```

### Implicit timeouts

Because `Rubium::Driver` uses `Selenium::WebDriver` under the hood, it supports its notion of an "implicit timeout". Implicit timeouts mean that any attempts to find an element will be repeated until the element is found or the timeout is reached.

Its important to note that implicit timeouts only affect driver methods such as `#find` or `#find_all`. They *do not* affect remote Javascript execution (such as when using the UIAutomation proxy API) and any Javascript errors will cause an immediate failure regardless of any implicit timeout that might be set.

The default implicit timeout is 1 second. Implicit timeouts can be set on the driver by using the `#implicit_timeout=` or `#with_implicit_timeout` methods. 

Note: use of implicit timeouts is discouraged unless you really need to make use of the low-level element finder APIs and access to them may be removed in the future.

### Native timeouts

Native timeouts are a form of implicit timeout that are managed on the Instruments Javascript runtime side of the process and use the `UIATarget` methods `setTimeout()`, `pushTimeout()` and `popTimeout()` and are only applicable when using the Javascript proxy APIs or when calling `Rubium::Driver#execute` directly.

The advantage of native timeouts over implicit driver timeouts or explicit timeouts is that they only ever require a single request to the Appium server - the Javascript statement will be executed once and will wait to return up to the timeout. The most typical use case is if you need to interact with an element in some way (such as tapping it) but it might not yet be valid (as you might be in the middle of a screen transition).

Whilst you can call `#set_timeout`, `#push_timeout` and `#pop_timeout` directly on the target proxy, you can also use the `Rubium::Driver` methods `#native_timeout=` and `#with_native_timeout`. The former will set the timeout permanently, the latter will push a new timeout value, invoke a Ruby block and then pop the timeout again.

Whenever you're dealing with elements using the proxy API, native timeouts should be your preferred means of handling delays.

### Explicit timeouts

The final type of timeout you might use is an explicit wait. Explicit timeouts work in the same way as implicit timeouts except as the name suggests, they are used explicitly. Like implicit timeouts, explicit timeouts will repeatedly execute a block of code until a timeout is reached. 

Unlike implicit timeouts, explicit timeouts can be used with any block of code, including calls to the Javascript proxy API. Native timeouts are the preferred way of interacting with elements that might not yet be on screen however there may be occasions where you want your script to explicitly wait for an element to be in a certain state. If this is the case, you can use an explicit timeout:

```ruby
# explicitly wait until an element is visible
window = driver.target.front_most_app.main_window
element = window.elements[0]
driver.wait_until { element.visible? }
```

The default timeout is 1 second. You can specify a specific timeout and the interval to wait between retries:

```ruby
driver.wait_until(timeout: 10, interval: 0.3) { element.visible? }
```

### TODO

* Document how you can use this from within a testing framework such as Cucumber or RSpec


