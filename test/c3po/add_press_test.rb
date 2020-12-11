# encoding: utf-8
require_relative '../test_helper'

# TS-330: C3PO Regression
# UI Test: Press
class AddPressTest < Common
  def setup
    super

    C3PO.setup(@browser)


    @title = 'Press Title'
    @link = 'http://www.google.com/'
    @notes = 'Press NotesPress NotesPress NotesPress Notes'
  end

  def teardown
    super
  end

  def press_section
    @browser.element(class: 'athletic_presses')
  end

  def fill_out_form
    # open form
    press_section.element(class: 'add_icon').click
    form = @browser.element(id: 'athletic_presses_edit')

    # fill out textboxes
    form.element(name: 'title').send_keys @title
    form.element(name: 'link').send_keys @link
    form.element(name: 'notes').send_keys @notes

    # submit form
    form.element(class: 'save').click; sleep 1
  end

  def check_added_press
    boxes = press_section.elements(class: 'box_list')
    refute_empty boxes, 'No box show up after added press'
  end

  def check_profile_history
    # go to Preview Profile
    @browser.element(class: 'button--primary').click; sleep 1

    section =  @browser.element(id: 'athletic-section')
    press = section.elements(tag_name: 'a').to_a.sample

    actual_link = press.attribute('href')
    assert_equal @link, actual_link, 'Incorrect press url'

    press.click
    assert (@browser.windows.length > 1), 'Clicking press not open new tab'
  end

  def test_add_press
    email = 'test1063@yopmail.com'
    UIActions.user_login_2(email)
    sleep 5
    UIActions.goto_edit_profile

    C3PO.goto_athletics

    # add a few press
    for i in 1 .. 3
      fill_out_form
    end

    check_added_press
    check_profile_history
  end
end
