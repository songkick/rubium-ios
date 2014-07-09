require 'rspec'

unless ENV['TM_FILEPATH']
  require 'simplecov'
  require "codeclimate-test-reporter"
  require 'coveralls'
  
  formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  formatters << CodeClimate::TestReporter::Formatter if ENV['CODECLIMATE_REPO_TOKEN']

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]
  
  unless ENV['skip_coverage']
    SimpleCov.start do
      add_filter "/spec/"
    end
  end
end

RSpec.configure do |config|
end

require 'support/matchers'
require 'appium_ios_driver'
