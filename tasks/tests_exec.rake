require 'rake/testtask'
require 'minitest-ci'

Minitest::Ci.new.start

namespace :first_run do 
  desc 'execute all tests....'
  task :exec, [:dir] do |t, args|
    puts "[INFO] First run attempt"

    args.with_defaults(dir: '**')
    test_files = FileList["test/daily_monitor/partners_pages_test.rb"]#["test/#{args.dir}/*_test.rb"]
    test_files.reject! { |e| e.empty? }

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
    end
  end

  desc 'display test run results....'
  task :result do
    begin 
      ruby 'calc.rb'
    rescue StandardError => e
      pp "[ERROR] Running calc.rb - #{e}"
    end
  end
end
