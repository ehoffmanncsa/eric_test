# encoding: utf-8
require_relative '../test_helper'
require_relative '../../preps/add_new_recruit_to_fasttrack'

# TS-38
# UI Test: POS Regression - How to Add New Recruit to Fasttrack
class AddRecruitToFasttrackTest < Minitest::Test
  def setup
    config = YAML.load_file('config/config.yml')
    @fasttrack_login = config['pages']['fasttrack_login']
    @info = config['recruit']

    # add a new recruit and get back his email address
    @recruit_email = FasttrackAddNewRecruit.new.main

    @ui = LocalUI.new(true)
    @browser = @ui.driver
  end

  def teardown
    @browser.quit
  end

  # verify the new recruit we added earlier can be found
  # also verify the edit, delete and duplicate buttons are available
  def test_find_new_recruit
    @ui.fasttrack_login

    wait = @ui.wait(30)
    update = @browser.find_element(:xpath, '//*[@id="nav"]/li[2]')
    @browser.action.move_to(update).perform
    @browser.find_element(:link_text, 'Recruit').click

    wait.until { @browser.find_element(:id, 'content').displayed? }
    assert (@browser.page_source.include? 'Search Recruits'), 'Search Recruits form not found'

    @browser.find_element(:name, 'emailAddress').send_keys @recruit_email
    @browser.find_element(:name, 'Submit').click
    @browser.manage.timeouts.implicit_wait = 30

    begin
      wait.until { @browser.find_element(:class, 'dataTables_wrapper').displayed? }
    rescue StandardError => e
      puts "[ERROR] #{e}"
    end

    table = @browser.find_element(:class, 'breakdowndatatable')
    refute_empty table.find_elements(:tag_name, 'input'), 'Cannot find the buttons in data table'
  end
end
