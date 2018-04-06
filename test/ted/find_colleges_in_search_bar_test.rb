# encoding: utf-8
require_relative '../test_helper'

# TS-382: TED Regression
# UI Test: Find College Filters

=begin
  Coach Admin Tiffany
  Find colleges using search bar:
    - In search bar: by school name, by state
=end

class FindCollegesSearchBarTest < Common
  def setup
    super
    TED.setup(@browser)

    goto_find_colleges
  end

  def goto_find_colleges
    UIActions.ted_login
    TED.goto_colleges
  end

  def search_for(key)
    search_bar = @browser.text_field(:class, 'form-control')
    search_key = key
    search_bar.set search_key
    search_bar.send_keys :enter

    UIActions.wait_for_spinner
  end

  def colleges
    @browser.elements(:class, 'card-college').to_a
  end

  def test_find_by_college_name
    search_key = 'Northern Illinois University'
    search_for(search_key)
    assert @browser.element(:class, 'card-college').present?, 'No college card found'

    college_name = colleges[0].element(:tag_name, 'h4').text
    assert_equal search_key, college_name, 'Incorrect college shows up'
  end

  def test_find_by_location
    search_for('Texas')
    assert @browser.element(:class, 'card-college').present?, 'No college card found'

    college = colleges.sample
    college_info = college.element(:class, 'subtitle').text
    assert_includes college_info, 'TX', 'College not from Texas'
  end
end
