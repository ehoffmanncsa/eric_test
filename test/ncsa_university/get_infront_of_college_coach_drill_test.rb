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

    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)

    POSSetup.setup(@browser)
    POSSetup.set_password(@email)
  end

  def teardown
    @browser.close
  end

  def content_area
    @browser.element(:class, 'content-area')
  end

  def form
    content_area.element(:tag_name, 'form')
  end

  def select_dropdown(id)
    dropdown = form.element(:id, id)
    options = dropdown.elements(:tag_name, 'option').to_a
    options.shift;
    options.reject! { |o| o.text == 'None' }
    options.sample.click
  end

  def select_drill
    UIActions.goto_ncsa_university
    drills = @browser.elements(:class, 'drill')
    drills.each do |d|
      item = d.element(:class, 'recruiting_u_default')
      if item.attribute('data-drill-name-id') == '28'
        item.element(:class, 'icon').click
        break
      else
        next
      end
    end
  end

  def verify_free_onboarding
    header = content_area.element(:tag_name, 'h1').text
    assert_includes header, @firstname

    content_area.element(:class, 'button--primary').click
  end

  def verify_commitment
    msg = 'Drill questions not found on commitment page'
    assert content_area.element(:class, 'drill-questions').visible?, msg
    questions = content_area.elements(:class, 'button--clear-dark').to_a
    questions.sample.click
  end

  def verify_location
    expect_p = "Let’s give coaches your academic info - they need this to recruit you."
    actual_p = content_area.element(:tag_name, 'p').text
    assert_equal expect_p, actual_p, 'Location page has incorrect header'

    # check next button not enable before fill in info
    assert (form.element(:class, 'button--disabled-dark').visible?), 'Button enabled before entering data'

    # fill in form
    form.element(:id, 'zip-code').send_keys MakeRandom.number(5)
    spinner = form.element(:id, 'high-school-select-spinner')
    Watir::Wait.while { spinner.visible? }
    %w(profile_data_high_school_id profile_data_gpa).each do |id|
      select_dropdown(id)
    end

    # now check button is enabled
    assert (form.element(:id, 'next').enabled?), 'Button not enabled after entering data'

    # do some checks on the skip modal
    verify_skip_modal

    form.element(:id, 'next').click
  end

  def verify_skip_modal
    form.elements(:class, 'skip-screen').last.click
    assert @browser.element(:id, 'skipping'), 'Skipping modal not visible'

    # make sure header text is right
    modal = @browser.element(:id, 'skipping')
    content = modal.element(:class, 'skip-content')
    expect_p = 'Hold on a second!'
    actual_p = content.element(:tag_name, 'p').text
    assert_equal actual_p, expect_p, 'Incorrect skip modal header'

    # make sure buttons are enabled
    failure = []
    failure << 'Green button not enabled' unless modal.element(:id, 'skip-close').enabled?
    failure << 'Dark button not enabled' unless modal.element(:class, 'button--clear-dark').enabled?
    assert_empty failure

    # close modal to continue
    modal.element(:id, 'skip-close').click; sleep 0.5
  end

  def verify_position
    # check next button not enable before fill in info
    assert (form.element(:class, 'button--disabled-dark').visible?), 'Button enabled before entering data'

    # select positions
    %w(profile_data_primary_position_id profile_data_secondary_position_id).each do |id|
      select_dropdown(id)
    end

    # now check button is enabled
    assert (form.element(:id, 'next').enabled?), 'Button not enabled after entering data'

    form.element(:id, 'next').click
  end

  def verify_player_stats
    expect_p = "Great! Let's add some quick stats for coaches to find."
    actual_p = content_area.element(:class, 'bigger').text
    assert_equal expect_p, actual_p, 'Player stats page has incorrect header'

    # check next button not enable before fill in info
    assert (form.element(:class, 'button--disabled-dark').visible?), 'Button enabled before entering data'

    # fill in height and weight
    select_dropdown('profile_data_height')
    form.element(:id, 'profile_data_weight').send_keys rand(120 ... 300)

    # now check button is enabled
    assert (form.element(:id, 'next').enabled?), 'Button not enabled after entering data'

    form.element(:id, 'next').click
  end

  def select_key_stats
    form.elements(:class, 'custom-select').each do |cs|
      dropdown = cs.element(:tag_name, 'select')
      dropdown.click
      options = dropdown.elements(:tag_name, 'option').to_a
      options.shift; options.reject! { |o| o.text == 'None' }
      options.sample.click
    end
  end

  def fill_in_key_stats
    form.elements(:class, 'custom-input').each do |i|
      input = i.element(:tag_name, 'input')
      value = input.attribute('placeholder').split(' ')[1]
      input.send_keys value
    end
  end

  def verify_key_stats
    expect_p = "Let's add some key stats specific to your sport too."
    actual_p = content_area.element(:class, 'bigger').text
    assert_equal expect_p, actual_p, 'Key stats page has incorrect header'

    # check next button not enable before fill in info
    assert (form.element(:class, 'button--disabled-dark').visible?), 'Button enabled before entering data'

    # fill in stats
    begin
      select_key_stats if form.elements(:class, 'custom-select')
    rescue; end

    begin
      fill_in_key_stats if form.elements(:class, 'custom-input')
    rescue; end

    # now check button is enabled
    assert (form.element(:id, 'next').enabled?), 'Button not enabled after entering data'

    form.element(:id, 'next').click
  end

  def verify_familiar
    expect_p = "Congratulations! Coaches can find, view, and contact you. " \
               "Now let’s see how we can help you with recruiting."
    actual_p = content_area.element(:class, 'bigger').text
    assert_equal expect_p, actual_p, 'Familiar page has incorrect header'

    msg = 'Drill questions not found on familiar page'
    assert content_area.element(:class, 'drill-questions').visible?, msg

    questions = content_area.elements(:class, 'button--clear-dark').to_a
    questions.sample.click
  end

  def verify_customize
    expect_p = 'What areas do you need the most help in? Pick all that apply.'
    actual_p = content_area.element(:class, 'bigger').text
    assert_equal expect_p, actual_p, 'Customize page has incorrect header'

    # check next button not enable before fill in info
    assert (form.element(:class, 'button--disabled-dark').visible?), 'Button enabled before entering data'

    # pick random programs
    customs = form.elements(:class, 'custom-input').to_a
    customs.sample.click

    # now check button is enabled
    assert (form.element(:id, 'next').enabled?), 'Button not enabled after entering data'

    form.element(:id, 'next').click
  end

  def verify_club_information
    expect_p = 'Add Your Team Info'
    actual_p = content_area.element(:class, 'larger').text
    assert_equal expect_p, actual_p, 'Club information page has incorrect header'

    # check next button not enable before fill in info
    assert (form.element(:class, 'button--disabled-dark').visible?), 'Button enabled before entering data'

    # fill out form
    # radios = form.elements(:type, 'radio').to_a
    # radios[0..1].sample.click; radios[2..3].sample.click
    form.element(:id, 'club_data_club_name-selectized').send_keys MakeRandom.name
    form.element(:id, 'club_data_name').send_keys MakeRandom.name
    form.element(:id, 'club_data_phone').send_keys MakeRandom.number(10)
    form.element(:id, 'club_data_email').send_keys 'dfsaofsa@fake.com'
    select_dropdown('club_data_coach_type')

    # now check button is enabled
    assert (form.element(:id, 'next').enabled?), 'Button not enabled after entering data'

    form.element(:id, 'next').click
  end

  def verify_done
    expect_p = 'Way to Finish Strong!'
    actual_p = content_area.element(:tag_name, 'h1').text
    assert_equal expect_p, actual_p, 'Done page has incorrect header'

    # check button is enabled
    assert (content_area.element(:class, 'button--primary').enabled?), 'Launch button not enabled'

    # check progress bar is max
    progress_bar = content_area.element(:tag_name, 'progress')
    bar_value = progress_bar.attribute('value').to_i
    assert_equal 100, bar_value, "Progress bar not max - #{bar_value}"
  end

  def test_complete_get_infront_of_coach_drill
    select_drill

    # verify each page of the progress except for last page
    loop do
      url = @browser.url
      end_point = url.split('/').last
      break if end_point.include? 'done'
      send("verify_#{end_point}")
    end

    # verify last page
    verify_done

    # now drill should be marked completed
    UIActions.goto_ncsa_university
    timeline_history = @browser.element(:class, 'timeline-history')
    
    drill_point = timeline_history.element(:css, 'li.drill.point.complete')
    expect_title = 'Get In Front of College Coaches'
    title = drill_point.element(:class, 'drill-title').text
    assert_equal expect_title, title, "Not the expected title"
  end
end
