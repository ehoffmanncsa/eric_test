# frozen_string_literal: true

require_relative '../test_helper'

# Regression
# UI Test: Verify user can favorite colleges on the find colleges page and have
# those colleges display on the favorites page.
class FindCollegesFavoritesTest < Common
  def setup
    super
    email = 'ncsa.automation+e6cc@gmail.com'

    C3PO.setup(@browser)
    UIActions.user_login(email, 'ncsa1333')
  end

  def teardown
    super
  end

  def filter_on_illinois
    @browser.element(id: 'college_search_college_name').send_keys 'Illinois'
    sleep 2
    @browser.button(name: 'commit').click
    sleep 3
  end

  def select_colleges
    i = 0
    rand(2..7).times do
      star = @browser.elements(class: 'favorite').to_a
      star.sample.click
      sleep 2
      i += 1
    end
  end

  def check_favorite_colleges
    failure = []
    failure << 'College favorite not found' unless @browser.html.include? 'Illinois'
    assert_empty failure
  end

  def select_favorite_rank
    # The text to break the loop in deselect only displays when favorite rank is selected
    dropdown = @browser.element(id: 'sort-view')
    options = dropdown.elements(tag_name: 'option').to_a

    options.each do |option|
      option.click if option.value == 'favorite_rank'
    end
  end

  def colleges_favorites
    star = @browser.element(class: 'favorite')
    star.click
  end

  def deselect_colleges
    loop do
      colleges_favorites
      break if @browser.html.include? 'Search for your favorite colleges now!'
    end
  end

  def clientrms_sign_out
    @browser.element(class: 'fa-angle-down').click
    navbar = @browser.element(id: 'secondary-nav-menu')
    navbar.link(text: 'Logout').click
  end

  def test_find_colleges_favorites
    UIActions.close_supercharge
    UIActions.goto_find_colleges
    filter_on_illinois
    select_colleges
    UIActions.goto_favorites
    sleep 1
    select_favorite_rank
    sleep 2
    check_favorite_colleges
    deselect_colleges
    sleep 1
    clientrms_sign_out
  end
end
