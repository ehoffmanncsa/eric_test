require 'rake/testtask'
require 'json'
require 'pp'

namespace :second_run do
  desc 're-run failed tests from first run attempt....'
  task :exec do
    test_files = JSON.parse(File.read('first_run_failed_tests.json'))
    exit if test_files.empty?

    test_files.reject! { |e| e.empty? }
    puts "\n[INFO] Re-running failed tests from first run attempt"

    test_files.each do |file, function|
      puts "\n[INFO] Executing....#{file} case #{function}"
      begin
        ruby "#{file} -n #{function}"
      rescue StandardError => e
        puts "Rake Rescue: failures/errors running #{file} case #{function}"
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

    test_files = JSON.parse(File.read('first_run_failed_tests.json'))
    exit 1 unless test_files.empty?
  end
end
