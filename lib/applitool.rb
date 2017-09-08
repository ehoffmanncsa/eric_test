# encoding: utf-8
require 'eyes_selenium'

class Applitool

  attr_accessor :eyes

  def initialize api_key, match_level
    self.eyes = Applitools::Selenium::Eyes.new
    eyes.api_key = api_key
    eyes.force_full_page_screenshot = true
    #eyes.use_css_transition = true;
    eyes.hide_scrollbars = true
    eyes.match_timeout = 3
    eyes.match_level = match_level
  end

  def action
    return eyes
  end

  def open driver, test_name
    eyes.open(driver: driver, app_name: 'NCSA WWW', test_name: test_name)
  end

  def screenshot pic_name
    eyes.check_window pic_name
  end

  def check_ignore pic_name, element
    eyes.check pic_name, Applitools::Selenium::Target.window.ignore(element)
  end
end
