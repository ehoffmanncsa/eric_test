# encoding: utf-8
require_relative '../test_helper'

# TS-248: NCSA University Regression
# UI Test: Get in front of college Coaches Drill
class GetInFrontOfCollegeCoachDrillTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]
    @firstname = post_body[:recruit][:athlete_first_name]
    pp @email, @firstname
    @firstname[0] = @firstname[0].capitalize

    @ui = LocalUI.new(true)
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@ui)

    POSSetup.set_password(@email)
  end

  def teardown
    @browser.quit
  end

  def content_area
    @browser.find_element(:class, 'content-area')
  end

  def verify_onboarding
    #UIActions.user_login(@email); sleep 1
    UIActions.goto_ncsa_university
    drills = @browser.find_elements(:class, 'drill')
    drills.each do |d|
      item = d.find_element(:class, 'recruiting_u_default')
      if item.attribute('data-drill-name-id') == '28'
        item.find_element(:class, 'icon').click
        break
      else
        next
      end
    end
 
    header = content_area.find_element(:tag_name, 'h1').text
    assert_includes header, @firstname
  end

  def verify_commitment
    content_area.find_element(:class, 'button--primary').click
    msg = 'Drill questions not found on commitment page'
    assert content_area.find_element(:class, 'drill-questions').displayed?, msg
  end

  def verify_location
    questions = content_area.find_elements(:class, 'button--clear-dark')
    questions.sample.click
    expect_p = 'Let’s give coaches your academic info - they need this to recruit you.'
    actual_p = content_area.find_element(:tag_name, 'p').text
    assert_equal expect_p, actual_p, 'Location page has incorrect header'

    # check next button not enable before fill in info
    form = content_area.find_element(:tag_name, 'form')
    refute (form.find_element(:id, 'next').enabled?), 'Button enabled before entering data'

    # fill in form
    form.find_element(:id, 'zip-code').send_keys MakeRandom.number(5)
    %w(profile_data_high_school_id profile_data_gpa).each do |id|
      dropdown = form.find_element(:id, id)
      dropdown.click
      options = dropdown.find_elements(:tag_name, 'option')
      options.shift; options.sample.click
    end

    # now check button is enabled
    assert (form.find_element(:id, 'next').enabled?), 'Button not enabled after entering data'

    # check skip-screen links enabled
    form.find_elements(:class, 'skip-screen').each do |e|
      failure = []
      failure << 'Skip screen link not enabled' unless e.enabled?
    end
    assert_empty failure
  end

  def

  def test_complete_get_infront_of_coach_drill
    goto_onboarding
  end
end

# https://qa.ncsasports.org/clientrms/custom_drills/free_onboarding/location

