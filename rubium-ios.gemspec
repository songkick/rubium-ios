# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'rubium/version'

Gem::Specification.new do |s|
  s.name          = "rubium-ios"
  s.version       = Rubium::Version.to_s
  s.authors       = ["Luke Redpath"]
  s.email         = ["luke@lukeredpath.co.uk"]
  s.homepage      = "https://github.com/songkick/rubium-ios"
  s.summary       = "A Ruby library for driving your iOS automated tests using Appium"
  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.license       = 'MIT'

  # developer dependencies
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rake', '~> 10.0'

  # runtime dependencies (used to generate Gemfile)
  s.add_runtime_dependency 'selenium-webdriver', '~> 2.42'
  s.add_runtime_dependency 'activesupport', '~> 3.0'
end
