# This example will start an Appium session, create a driver and then drop into a Pry debugging session.
#
# You'll need to have the Appium server running on your local machine on the default port. The
# quickest way to get up and running with Appium is to download Appium.app from http://appium.io
#
# You will need the pry and pry-byebug gems installed to run this example.
#
require 'appium_ios_driver'
require 'pry-byebug'

### CUSTOMISE THIS SECTION

# the path to your compiled app (simulator build)
APP_PATH = ''

# your app's bundle ID
APP_BUNDLE_ID = ''

# the amount of time before Appium will quit after not receiving any commands
COMMAND_TIMEOUT = 600 # 10 minutes

### END CUSTOMISATION

# define the capabilities for our appium session
capabilities = Appium::Capabilities::Simulator.new do |capabilities|
  capabilities.device_name = 'iPhone Simulator'
  capabilities.app = APP_PATH
  capabilities.bundle_id = APP_BUNDLE_ID
  capabilities.auto_accept_alerts = true
  capabilities.new_command_timeout = COMMAND_TIMEOUT
end

# create the driver
driver = Appium::IOSDriver.new(capabilities)

# start the session
puts "Starting Appium session..."
driver.with_session do
  #
  # begin console session here
  # type 'continue' at the console to finish the session (and quit the simulator)
  #
  binding.pry
end
