require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:specs) do |t|
  t.pattern = 'specs/**/*_spec.rb'
  t.rspec_opts = '--color'
end

namespace :docs do
  desc "Reports documentation coverage using inch"
  task(:coverage) { sh "bundle exec inch" }
end

task :default => :specs
