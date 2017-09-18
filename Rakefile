require 'rake/testtask'
require 'parallel'
require 'rake'

# save tasks in the tasks dir to keep this Rakefile cleaner
Dir.glob("#{File.expand_path('../tasks', __FILE__)}/*.rake").each { |f| import f }

task :test do
  task(:tests_exec).execute
  # task(:tests_result).execute
  # task(:tests_rerun).execute
  # task(:tests_result).execute
end

task default: :test