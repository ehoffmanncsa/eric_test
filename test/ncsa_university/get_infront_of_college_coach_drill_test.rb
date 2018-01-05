# encoding: utf-8
require_relative '../test_helper'

# TS-248: NCSA University Regression
# UI Test: Get in front of college Coaches Drill
class GetInFrontOfCollegeCoachDrillTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]
    @firstname = post_body[:recruit][:athlete_first_name]
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

  def form
    content_area.find_element(:tag_name, 'form')
  end

  def select_dropdown(id)
    dropdown = form.find_element(:id, id)
    dropdown.click
    options = dropdown.find_elements(:tag_name, 'option')
    options.shift;
    options.reject! { |o| o.text == 'None' }
    options.sample.click
  end

  def select_drill
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
  end

  def verify_free_onboarding
    header = content_area.find_element(:tag_name, 'h1').text
    assert_includes header, @firstname

    content_area.find_element(:class, 'button--primary').click; sleep 1
  end

  def verify_commitment
    msg = 'Drill questions not found on commitment page'
    assert content_area.find_element(:class, 'drill-questions').displayed?, msg
    questions = content_area.find_elements(:class, 'button--clear-dark')
    questions.sample.click; sleep 1
  end

  def verify_location
    expect_p = "Let’s give coaches your academic info - they need this to recruit you."
    actual_p = content_area.find_element(:tag_name, 'p').text
    assert_equal expect_p, actual_p, 'Location page has incorrect header'

    # check next button not enable before fill in info
    assert (form.find_element(:class, 'button--disabled-dark').displayed?), 'Button enabled before entering data'

    # fill in form
    form.find_element(:id, 'zip-code').send_keys MakeRandom.number(5)
    spinner = form.find_element(:id, 'high-school-select-spinner')
    UIActions.wait.until { spinner.attribute('style').include? 'display: none' }
    %w(profile_data_high_school_id profile_data_gpa).each do |id|
      select_dropdown(id)
    end

    # now check button is enabled
    assert (form.find_element(:id, 'next').enabled?), 'Button not enabled after entering data'

    # do some checks on the skip modal
    verify_skip_modal

    form.find_element(:id, 'next').click; sleep 1
  end

  def verify_skip_modal
    form.find_elements(:class, 'skip-screen').last.click; sleep 1
    assert @browser.find_element(:id, 'skipping'), 'Skipping modal not displayed'

    # make sure header text is right
    modal = @browser.find_element(:id, 'skipping')
    content = modal.find_element(:class, 'skip-content')
    expect_p = 'Hold on a second!'
    actual_p = content.find_element(:tag_name, 'p').text
    assert_equal actual_p, expect_p, 'Incorrect skip modal header'

    # make sure buttons are enabled
    failure = []
    failure << 'Green button not enabled' unless modal.find_element(:id, 'skip-close').enabled?
    failure << 'Dark button not enabled' unless modal.find_element(:class, 'button--clear-dark').enabled?
    assert_empty failure

    # close modal to continue
    modal.find_element(:id, 'skip-close').click; sleep 1
  end

  def verify_position
    # check next button not enable before fill in info
    assert (form.find_element(:class, 'button--disabled-dark').displayed?), 'Button enabled before entering data'

    # select positions
    %w(profile_data_primary_position_id profile_data_secondary_position_id).each do |id|
      select_dropdown(id)
    end

    # now check button is enabled
    assert (form.find_element(:id, 'next').enabled?), 'Button not enabled after entering data'

    form.find_element(:id, 'next').click; sleep 1
  end

  def verify_player_stats
    expect_p = "Great! Let's add some quick stats for coaches to find."
    actual_p = content_area.find_element(:class, 'bigger').text
    assert_equal expect_p, actual_p, 'Player stats page has incorrect header'

    # check next button not enable before fill in info
    assert (form.find_element(:class, 'button--disabled-dark').displayed?), 'Button enabled before entering data'

    # fill in height and weight
    select_dropdown('profile_data_height')
    form.find_element(:id, 'profile_data_weight').send_keys rand(120 ... 300)

    # now check button is enabled
    assert (form.find_element(:id, 'next').enabled?), 'Button not enabled after entering data'

    form.find_element(:id, 'next').click; sleep 1
  end

  def select_key_stats
    form.find_elements(:class, 'custom-select').each do |cs|
      dropdown = cs.find_element(:tag_name, 'select')
      dropdown.click
      options = dropdown.find_elements(:tag_name, 'option')
      options.shift; options.reject! { |o| o.text == 'None' }
      options.sample.click
    end
  end

  def fill_in_key_stats
    form.find_elements(:class, 'custom-input').each do |i|
      input = i.find_element(:tag_name, 'input')
      value = input.attribute('placeholder').split(' ')[1]
      input.send_keys value
    end
  end

  def verify_key_stats
    expect_p = "Let's add some key stats specific to your sport too."
    actual_p = content_area.find_element(:class, 'bigger').text
    assert_equal expect_p, actual_p, 'Key stats page has incorrect header'

    # check next button not enable before fill in info
    assert (form.find_element(:class, 'button--disabled-dark').displayed?), 'Button enabled before entering data'

    # fill in stats
    begin
      select_key_stats if form.find_elements(:class, 'custom-select')
    rescue; end

    begin
      fill_in_key_stats if form.find_elements(:class, 'custom-input')
    rescue; end

    # now check button is enabled
    assert (form.find_element(:id, 'next').enabled?), 'Button not enabled after entering data'

    form.find_element(:id, 'next').click; sleep 1
  end

  def verify_familiar
    expect_p = "Congratulations! Coaches can find, view, and contact you. " \
               "Now let’s see how we can help you with recruiting."
    actual_p = content_area.find_element(:class, 'bigger').text
    assert_equal expect_p, actual_p, 'Familiar page has incorrect header'

    msg = 'Drill questions not found on familiar page'
    assert content_area.find_element(:class, 'drill-questions').displayed?, msg

    questions = content_area.find_elements(:class, 'button--clear-dark')
    questions.sample.click; sleep 1
  end

  def verify_customize
    expect_p = 'What areas do you need the most help in? Pick all that apply.'
    actual_p = content_area.find_element(:class, 'bigger').text
    assert_equal expect_p, actual_p, 'Customize page has incorrect header'

    # check next button not enable before fill in info
    assert (form.find_element(:class, 'button--disabled-dark').displayed?), 'Button enabled before entering data'

    # pick random programs
    customs = form.find_elements(:class, 'custom-input'); sleep 0.5
    customs.sample.click

    # now check button is enabled
    assert (form.find_element(:id, 'next').enabled?), 'Button not enabled after entering data'

    form.find_element(:id, 'next').click; sleep 1
  end

  def verify_club_information
    expect_p = 'Add Your Team Info'
    actual_p = content_area.find_element(:class, 'larger').text
    assert_equal expect_p, actual_p, 'Club information page has incorrect header'

    # check next button not enable before fill in info
    assert (form.find_element(:class, 'button--disabled-dark').displayed?), 'Button enabled before entering data'

    # fill out form
    custom = form.find_elements(:class, 'custom-input')
    inputs = []
    custom.each { |e| inputs << e.find_elements(:tag_name, 'input') }
    inputs.flatten!
    radios = inputs.select { |i| i.attribute('type') == 'radio' }
    radios[0..1].sample.click; radios[2..3].sample.click
    form.find_element(:id, 'club_data_club_name').send_keys MakeRandom.name
    form.find_element(:id, 'club_data_name').send_keys MakeRandom.name
    form.find_element(:id, 'club_data_phone').send_keys MakeRandom.number(10)
    form.find_element(:id, 'club_data_email').send_keys 'dfsaofsa@fake.com'
    select_dropdown('club_data_coach_type')

    for i in 1.. rand(inputs.length)
      inputs[i].click
    end

    # now check button is enabled
    assert (form.find_element(:id, 'next').enabled?), 'Button not enabled after entering data'

    form.find_element(:id, 'next').click; sleep 1
  end

  def verify_done
    expect_p = 'Way to Finish Strong!'
    actual_p = content_area.find_element(:tag_name, 'h1').text
    assert_equal expect_p, actual_p, 'Done page has incorrect header'

    # check button is enabled
    assert (content_area.find_element(:class, 'button--primary').enabled?), 'Launch button not enabled'

    # check progress bar is max
    progress_bar = content_area.find_element(:tag_name, 'progress')
    bar_value = progress_bar.attribute('value').to_i
    assert_equal 100, bar_value, "Progress bar not max - #{bar_value}"
  end

  def test_complete_get_infront_of_coach_drill
    select_drill

    # verify each page of the progress except for last page
    loop do
      url = @browser.current_url
      end_point = url.split('/').last
      break if end_point.include? 'done'
      send("verify_#{end_point}")
    end

    # verify last page
    verify_done

    # now drill should be marked completed
    UIActions.goto_ncsa_university
    timeline_history = @browser.find_element(:class, 'timeline-history')
    
    drill_point = timeline_history.find_element(:css, 'li.drill.point.complete')
    expect_title = 'Get In Front of College Coaches'
    title = drill_point.find_element(:class, 'drill-title').text
    assert_equal expect_title, title, "Not the expected title"
  end
end
