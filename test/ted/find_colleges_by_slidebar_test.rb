# encoding: utf-8
require_relative '../test_helper'

# TS-382: TED Regression
# UI Test: Find College Filters

=begin
  Coach Admin Tiffany
  Check college filters:
    - Filter results by slide bar options: enrollment size, tuition
    - Filter by each option individually
    - Filter by combining both options
=end

class FindCollegesBySlideBarTest < Common
  def setup
    super
    TED.setup(@browser)

    goto_find_colleges
  end

  def teardown
    super
  end

  def goto_find_colleges
    UIActions.ted_login
    TED.goto_colleges
    TED.open_college_filters
  end

  def apply_filters
    @browser.button(text: 'Search').click
    UIActions.wait_for_spinner
  end

  def colleges
    @browser.elements(class: 'card-college').to_a
  end

  def select_filter(element_id)
    # there are 6 selectors on slidebar
    # where aria-value indicates:
    # 0 for <1K, 1 for >= 5K, 2 for >= 10K, etc...
    # select 10k filter in this case
    section = @browser.div(id: element_id)
    slide_bar = section.element(class: 'rc-slider-with-marks')
    left_handle = slide_bar.element(class: 'rc-slider-handle-1')
    option_10k = slide_bar.elements(class: 'rc-slider-mark-text')[2]
    left_handle.drag_and_drop_on(option_10k)
  end

  def random_college
    # pick a random college, go to showpage
    college = colleges.sample
    college_name = college.element(tag_name: 'h4').text
    college.click
    UIActions.wait_for_spinner

    if @browser.element(class: 'alert-warning').present?
      @browser.refresh
      UIActions.wait_for_spinner
    end

    college_name
  end

  def check_enrollment_size
    failure = []
    colleges.each do |c|
      school = c.element(tag_name: 'h4').text
      subtitle = c.element(class: 'card-details').element(class: 'subtitle').text
      enrollments = subtitle.split(' ').last.gsub(',', '').to_i
      msg = "#{school} has #{enrollments} enrollments, expected >= 10k"
      failure << msg unless (enrollments >= 10000)
    end
    assert_empty failure
  end

  def check_in_state_tuition(college_name)
    # extract in state tuition from profile and compare
    tuition = UIActions.find_by_test_id('in-state-tuition').text.gsub(/[$,]/, '').to_i
    assert tuition >= 10000, "#{college_name} tuition is #{tuition}, expected >= 10k"
  end

  def test_filter_by_enrollment_size
    select_filter('ranger-slider-enrollmentRange')
    apply_filters
    check_enrollment_size
  end

  def test_filter_by_tuition
    select_filter('ranger-slider-tuitionRange')
    apply_filters
    check_in_state_tuition(random_college)
  end

  def test_filter_by_enrollment_tuition
    select_filter('ranger-slider-enrollmentRange')
    select_filter('ranger-slider-tuitionRange')
    apply_filters
    check_enrollment_size
    check_in_state_tuition(random_college)
  end
end
