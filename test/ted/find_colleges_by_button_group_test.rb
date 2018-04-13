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

  def goto_find_colleges
    UIActions.ted_login
    TED.goto_colleges
  end

  def open_filter
    @browser.button(:text, 'Define Search').click
  end

  def apply_filters
    @browser.button(:text, 'Search').click
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
    open_filter
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
    open_filter
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
    open_filter
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
    open_filter
    strength = select_filter('button-group-academicStrength').downcase
    apply_filters

    # pick a random college, go to showpage
    college = colleges.sample
    college_name = college.element(:tag_name, 'h4').text
    college.click; sleep 1

    # extract selectivity from profile and compare
    profile = @browser.element(:class, 'college-profile')
    col = profile.div(:class, 'col-lg-7')
    table = col.tables(:class, 'box')[0]
    selectivity = table.trs[2].td(:index, 0).text.downcase
    msg = "#{college_name} selectivity is #{selectivity}, expected #{strength}"
    assert_equal strength, selectivity, msg
  end
end
