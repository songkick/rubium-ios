require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:specs) do |t|
  t.pattern = 'specs/**/*_spec.rb'
  t.rspec_opts = '--color'
end

task :default => :specs
