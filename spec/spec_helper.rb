require 'rspec'

unless ENV['TM_FILEPATH']
  require 'simplecov'
  SimpleCov.start unless ENV['skip_coverage']

  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']
  
  require 'coveralls'
  Coveralls.wear!
end

RSpec.configure do |config|
end

require 'support/matchers'
require 'appium_ios_driver'
