require 'bundler'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

begin
  require 'coveralls/rake/task'
  Coveralls::RakeTask.new
  task :spec_with_coveralls => [:spec, 'coveralls:push']
rescue LoadError
  # You can't install coveralls with jruby
  task :spec_with_coveralls => [:spec]
end