require 'rake/testtask'

def read_first_run_fail_files
  File.read('first_run_failed_tests').split(',')
end

namespace :second_run do
  desc 're-run failed tests from first run attempt....'
  task :exec do
  	test_files = read_first_run_fail_files
    exit if test_files.empty?

    test_files.reject! { |e| e.empty? }
    puts "\n[INFO] Re-running failed tests from first run attempt"

    test_files.each do |file|
      puts "\n[INFO] Executing....#{file}"
      begin
        Rake::TestTask.new(file) do |t|
            t.test_files = FileList[file]
            t.verbose = false
            t.warning = false  
        end

        task(file).execute
      rescue StandardError => e
        puts "Rake Recue: failures/errors running #{file}"
      end
    end
  end

  desc 'display test run results....'
  task :result do
    begin 
      ruby 'calc.rb'
    rescue StandardError => e
      puts "[ERROR] Running calc.rb - #{e}"
    end

    exit 1 unless test_files.empty?
  end
end