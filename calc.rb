#!/usr/bin/env ruby
require 'xmlsimple'
require 'pp'
require 'open3'

class Calc
  def initialize; end

  def get_xml_files
    files = Dir["test/reports/*.xml"].sort_by! { |x| x.split('/')[-1].downcase } #test/reports/*.xml
    return files unless block_given?
    files.each { |f| yield(f) }
  end

  def parse_xml(file)
    failures = []
    errors = []
    xml = File.read(file)
    data = XmlSimple.xml_in(xml)

    name = data['name']
    testcases = data['tests'].to_i
    asserts = data['assertions'].to_i

    err = data['errors']
    fails = data['failures']
    fail_files = nil

    if !fails.eql? '0'
      fail_file = data['testcase'].first['file']
      data['testcase'].each do |tc|
        fail_files = tc['file']
        unless tc['failure'].nil?
          tc['failure'].each do |f|
            failures << "#{tc['file']} #{name}.#{tc['name']}.failed"
          end
        end
      end
    end

    if !err.eql? '0'
      fail_file = data['testcase'].first['file']
      data['testcase'].each do |tc|
        fail_files = tc['file']
        unless tc['error'].nil?
          tc['error'].each do |e|
            errors << "#{tc['file']} #{name}.#{tc['name']}.error"
          end
        end
      end
    end

    # wrap up the testSuite into a single array result
    sum1 = "#{name}: seconds='#{data['time'].to_f}' skipped='#{data['skipped'].to_i}'"
    sum2 = "failures='#{fails}' errors='#{err}'"
    sum3 = "assertions='#{asserts}' tests='#{testcases}'"
    summary = ["#{sum1} #{sum2} #{sum3}"]

    return summary, data['time'].to_f, failures, errors, testcases, asserts, data['skipped'].to_i, fail_file
  end

  def sum(values)
    return values.inject { |a, e| a + e }.round.to_i
  end

  def test_suite_reports(row)
    puts "#{row}"
  end

  def tally(values)
    count = 0
    values.each do |tc|
      if tc.length > 1
        tc.each do
          count += 1
        end
      else
        count += 1
      end
    end
    count
  end

  def summary_display(summary, failures, errors)
    puts "\n#{summary}"
    failures.each do |f|
      puts "Failures: #{f}"
    end

    errors.each do |e|
      puts "Errors: #{e}"
    end

    if failures.length > 0 || errors.length > 0
      puts 'FAILED build'
    else
      puts 'SUCCESSFUL build'
    end
  end

  def iterate_through_files
    timings = [0]
    tests = [0]
    assertions = [0]
    failures = []
    errors = []
    skipped = [0]
    fail_files = []

    get_xml_files.each do |file|
      fails = []
      errs = []
      r = parse_xml(file)
      timings << r[1] unless r[1] == []
      failures << r[2] unless r[2] == []
      errors << r[3] unless r[3] == []
      tests << r[4] unless r[4] == []
      assertions << r[5] unless r[5] == []
      skipped << r[6] unless r[6] == []
      fail_files << r[7] unless r[7] == []

      test_suite_reports(r[0])
    end

    ##########
    # summary
    sum1 = "TOTAL: seconds='#{sum(timings)}' suites='#{get_xml_files.length}'"
    sum2 = "tests='#{sum(tests)}' assertions='#{sum(assertions)}'"
    sum3 = "failures='#{tally(failures)}' errors='#{tally(errors)}' skipped='#{sum(skipped)}'"
    summary = "#{sum1} #{sum2} #{sum3}"

    summary_display(summary, failures, errors)

    unless fail_files.empty?
      fail_files.each { |file| write_first_run_failed_tests(file) unless file.nil? }
    end
  end

  def open_first_run_failed_tests
    @first_run_failed_tests = open('first_run_failed_tests', 'w')
  end

  def write_first_run_failed_tests(file)
    @first_run_failed_tests << "#{file},"
  end

  def main
    puts "\n[INFO] Tests run result...."
    open_first_run_failed_tests
    iterate_through_files
  end
end

Calc.new.main