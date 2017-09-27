require 'rake/testtask'

def read_first_run_fail_files
  File.read('/tmp/first_run_failed_tests').split(',')
end

namespace :second_run do
  desc 're-run failed tests from first run attempt....'
  task :exec do
    puts "\n[INFO] Re-running failed tests from first run attempt"
  	test_files = read_first_run_fail_files
    test_files.reject! { |e| e.empty? }

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
  end
end