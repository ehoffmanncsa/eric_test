#!/usr/bin/env ruby
require 'rake/testtask'

# save tasks in the tasks dir to keep this Rakefile cleaner
tasks = '../tasks/*.rake'
Dir.glob(File.expand_path(tasks, __FILE__)) { |f| import f }

# default rake task is test task
# you can run this task by running: rake default, rake test, rake test <directory name>
# running rake test only will execute tests in all directories within the test/ directory
# providing a directory name will only execute tests within that directory
# the work flow is: execute tests once, produce results,
# run all failed test one more time and give final result
task default: :test
task :test, [:dir] => ['first_run:exec', 'first_run:result', 'second_run:exec', 'second_run:result'] do |t, arg|; end
