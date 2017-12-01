require 'rake/testtask'
require 'minitest-ci'

Minitest::Ci.new.start

exceptions = ['test/pos/enroll_mvp_user_freshman_test.rb',
              'test/pos/enroll_mvp_user_junior_test.rb',
              'test/daily_monitor/review_page_test.rb',
              'test/daily_monitor/homepage_test.rb',
              'test/daily_monitor/events_page_test.rb',
              'test/daily_monitor/partners_pages_test.rb',
              'test/daily_monitor/press_media_zip_download_test.rb',
              'test/daily_monitor/review_page_test.rb',
              'test/daily_monitor/ted_page_test.rb',
              'test/daily_monitor/contact_us_page_test.rb']

namespace :first_run do 
  desc 'execute all tests....'
  task :exec, [:dir] do |t, args|
    puts "[INFO] First run attempt, going to execute these tests:"

    args.with_defaults(dir: '**')
    if exceptions.empty?
      test_files = FileList["test/#{args.dir}/*_test.rb"]
    else
      test_files = FileList["test/#{args.dir}/*_test.rb"] - exceptions
    end
    puts test_files

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
