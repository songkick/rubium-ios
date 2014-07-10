require 'rake'
require 'rspec/core/rake_task'
require 'yard'
require 'rubium/version'

require_relative 'yard_ext'

RSpec::Core::RakeTask.new(:specs) do |t|
  t.pattern = 'specs/**/*_spec.rb'
  t.rspec_opts = '--color'
end

desc "Release a new version of the gem"
task :release do
  sh 'mkdir -p pkg'
  sh 'gem build rubium-ios.gemspec'
  sh "gem push rubium-ios-#{Rubium::Version}.gem"
end

namespace :docs do
  desc "Reports documentation coverage using inch"
  task(:coverage) { sh "bundle exec inch" }
  
  YARD::Rake::YardocTask.new(:generate) do |t|
    t.files = ['lib/**/*.rb']
  end
  
  desc "Start a local yard server"
  task :serve do
    sh "yard server -r -e yard_ext.rb"
  end
end

task :default => :specs
