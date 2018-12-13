require 'rake/testtask'
require 'minitest-ci'

Minitest::Ci.new.start

exceptions = ['test/membership_service/add_recruit_to_fasttrack_test.rb',
              'test/membership_service/enroll_use_ACH_payment_test.rb']

namespace :first_run do
  desc 'execute all tests....'
  task :exec do |t, args|
    # Read the test_dir from the command line. EX: `rake first_run:exec ted`
    test_dir = ARGV[1]
    args.with_defaults(dir: '**')
    test_files = FileList["test/#{args.dir}/*_test.rb"]
    if test_dir
      test_files = FileList["test/#{test_dir}/*_test.rb"]
    end

    # remove the exceptions tests from the test run
    test_files -= exceptions
    puts '[INFO] First run attempt, going to execute these tests:'
    puts test_files

    test_files.reject! { |file| file.empty? }
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
