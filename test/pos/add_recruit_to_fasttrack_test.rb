# encoding: utf-8
require_relative '../test_helper'

# TS-38
# UI Test: POS Regression - How to Add New Recruit to Fasttrack
class AddRecruitToFasttrackTest < Minitest::Test
  def setup
    @ui = LocalUI.new(true)
    @browser = @ui.driver

    # add a new recruit and get back his email address
    @recruit_email, _username = FasttrackAddNewRecruit.new.main
  end

  def teardown
    @browser.close
  end

  # verify the new recruit we added earlier can be found
  # also verify the edit, delete and duplicate buttons are available
  def test_find_new_recruit
    @ui.fasttrack_login

    wait = @ui.wait(30)
    @browser.get 'https://qa.ncsasports.org/fasttrack/lead/Search.do?method=preSearch'

    wait.until { @browser.find_element(:id, 'content').displayed? }
    assert (@browser.page_source.include? 'Search Recruits'), 'Search Recruits form not found'

    @browser.find_element(:name, 'emailAddress').send_keys @recruit_email
    @browser.find_element(:name, 'Submit').click
    @browser.manage.timeouts.implicit_wait = 30

    assert @browser.find_element(:class, 'dataTables_wrapper').displayed?, 'Cannot find search result data table'

    table = @browser.find_element(:class, 'breakdowndatatable')
    refute_empty table.find_elements(:tag_name, 'input'), 'Cannot find the buttons in data table'
  end
end
