require 'rspec'

unless ENV['TM_FILEPATH']
  require 'simplecov'
  require "codeclimate-test-reporter"
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    Coveralls::SimpleCov::Formatter,
    SimpleCov::Formatter::HTMLFormatter,
    CodeClimate::TestReporter::Formatter
  ]
  
  SimpleCov.start unless ENV['skip_coverage']
end

RSpec.configure do |config|
end

require 'support/matchers'
require 'appium_ios_driver'
