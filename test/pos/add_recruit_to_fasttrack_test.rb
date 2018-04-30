# encoding: utf-8
require_relative '../test_helper'

# TS-38: POS Regression
# UI Test:  How to Add New Recruit to Fasttrack
class AddRecruitToFasttrackTest < Common
  def setup
    # add a new recruit and get back his email address and name
    @recruit_email, @firstName, @lastName = FasttrackAddNewRecruit.new.main
    super
  end

  # verify the new recruit we added earlier can be found
  # also verify the edit, delete and duplicate buttons are available
  def test_find_new_recruit
    UIActions.fasttrack_login

    @browser.goto 'https://qa.ncsasports.org/fasttrack/lead/Search.do?method=preSearch'
    content = @browser.div(:id, 'content')
    header = content.element(:tag_name, 'h1').text
    assert_equal 'Search Recruits', header, 'Search Recruits form not found'

    # data comes back quite slow at times
    # give it a grace period and 3 tries before failing test
    begin
      retries ||= 0
      @browser.text_field(:name, 'emailAddress').set @recruit_email
      @browser.button(:name, 'Submit').click

      Watir::Wait.until { @browser.table(:class, 'breakdowndatatable').exists? }
      @table = @browser.table(:class, 'breakdowndatatable')
    rescue
      @browser.text_field(:name, 'emailAddress').clear
      retry if (retries += 1) < 3
    end

    assert @table.visible?, 'Cannot find newly added recruit after 30sec wait'

    # check if the return data has the correct name
    recruit_name = @table[1][3].text
    assert_equal "#{@firstName} #{@lastName}", recruit_name, 'Search data is incorrect'

    # make sure all buttons present and enabled
    btns = @table.elements(:tag_name, 'input')
    refute_empty btns, 'Cannot find the buttons in data table'

    failure = []
    btns.each do |b|
      failure << "#{b.text} button not enabled" unless b.enabled?
    end
    assert_empty failure
  end
end
