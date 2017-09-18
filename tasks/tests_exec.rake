require 'minitest-ci'

Minitest::Ci.new.start

desc 'run smoke tests in parallel..."'
task :tests_exec do
  test_files = FileList['test/**/*_test.rb']
  test_files.reject! { |e| e.empty? }
  test_files.each { |f| puts "[INFO] Executing....#{f}" }

  begin
    Rake::TestTask.new do |t|
      t.test_files = FileList[test_files]
      t.verbose = false
      t.warning = false  
    end
  rescue StandardError => e
    puts "Rake Rescue: failures/errors running #{e}"
  end
end
