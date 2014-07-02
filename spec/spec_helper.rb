require 'rspec'
require 'simplecov'

SimpleCov.start unless ENV['TM_FILEPATH']

RSpec.configure do |config|
end

require 'support/matchers'
require 'appium_ios_driver'
