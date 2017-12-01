require 'rake/testtask'
require 'pp'

namespace :second_run do
  desc 're-run failed tests from first run attempt....'
  task :exec do
    exit 0 if File.read('first_run_failed_tests').empty?
    test_files = File.read('first_run_failed_tests').split(',')

    puts "\n[INFO] Re-running below failed tests from first run attempt:"
    puts test_files

    test_files.each do |file|
      puts "\n[INFO] Executing ..... #{file}"
      begin
        Rake::TestTask.new(file) do |t|
          t.test_files = FileList[file]
          t.verbose = false
          t.warning = false
        end

        task(file).execute
      rescue StandardError => e
        puts "Rake Rescue: failures/errors #{e} running #{file}"
      end
      sleep 1
    end
  end

  desc 'display test run results....'
  task :result do
    begin
      ruby 'calc.rb'
    rescue StandardError => e
      puts "[ERROR] Running calc.rb - #{e}"
    end

    files = File.read('first_run_failed_tests')
    (files.empty?) ? (exit 0) : (exit 1)
  end
end
