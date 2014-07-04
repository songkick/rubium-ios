require 'rake'
require 'rspec/core/rake_task'
require 'yard'

require_relative 'yard_ext'

RSpec::Core::RakeTask.new(:specs) do |t|
  t.pattern = 'specs/**/*_spec.rb'
  t.rspec_opts = '--color'
end

namespace :docs do
  desc "Reports documentation coverage using inch"
  task(:coverage) { sh "bundle exec inch" }
  
  YARD::Rake::YardocTask.new(:generate) do |t|
    t.files = ['lib/**/*.rb']
  end
end

task :default => :specs
