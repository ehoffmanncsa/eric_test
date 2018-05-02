# encoding: utf-8
require_relative '../test_helper'

# TS-382: TED Regression
# UI Test: Find College Filters

=begin
  Coach Admin Tiffany
  Check college filters:
    - Filter results by: division, public/private, school type,
      enrollment size, tuition, region, selectivity, major
=end

class FindCollegesButtonGroupTest < Common
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
    @browser.button(:text, 'Search').click
    UIActions.wait_for_spinner
  end

  def clear_filters
    @browser.button(:text, 'Clear').click
    UIActions.wait_for_spinner
  end

  def colleges
    @browser.elements(:class, 'card-college').to_a
  end

  def select_filter(element_id)
    btn_group = @browser.element(:id, element_id)
    button = btn_group.elements(:class, 'btn').to_a.sample
    button.click

    button.text
  end

  def test_filter_result_by_division
    # skipping this test case until TED-1344 is addressed
    skip
    div_button = select_filter('button-group-division')
    apply_filters

    failure = []
    colleges.each do |c|
      school = c.element(:tag_name, 'h4').text
      subtitle = c.element(:class, 'card-details').element(:class, 'subtitle').text
      division = subtitle.split(' ')[0]
      failure << "#{school} is not in #{div_button}" unless division.eql? div_button
    end
    assert_empty failure
  end

  def test_filter_result_by_public_private
    option = select_filter('button-group-publicPrivate')
    apply_filters

    failure = []
    colleges.each do |c|
      school = c.element(:tag_name, 'h4').text
      tags = c.element(:class, 'card-details').element(:class, 'tag-group').text
      failure << "#{school} is not #{option}" unless tags.include? option
    end
    assert_empty failure
  end

  def test_filter_result_by_school_type
    type = select_filter('button-group-collegeType')
    apply_filters

    failure = []
    colleges.each do |c|
      school = c.element(:tag_name, 'h4').text
      tags = c.element(:class, 'card-details').element(:class, 'tag-group').text
      failure << "#{school} is not #{type} type" unless tags.include? type
    end
    assert_empty failure
  end

  def test_filter_result_by_selectivity
    strength = select_filter('button-group-academicStrength').downcase
    apply_filters

    # pick a random college, go to showpage
    college = colleges.sample
    college_name = college.element(:tag_name, 'h4').text
    college.click
    UIActions.wait_for_spinner

    # extract selectivity from profile and compare
    profile = @browser.element(:class, 'college-profile')
    col = profile.div(:class, 'col-lg-7')
    table = col.tables(:class, 'box')[0]
    selectivity = table.trs[2].td(:index, 0).text.downcase
    msg = "#{college_name} selectivity is #{selectivity}, expected #{strength}"
    assert_equal strength, selectivity, msg
  end

  def test_clear_btn_does_not_disable_search
    select_filter('button-group-collegeType')
    apply_filters

    assert colleges.any?

    clear_filters
    assert_empty colleges

    select_filter('button-group-collegeType')
    apply_filters
    assert colleges.any?
  end
end
