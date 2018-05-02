# encoding: utf-8
require 'eyes_selenium'

class Applitool
  attr_accessor :eyes

  def initialize match_level
    self.eyes = Applitools::Selenium::Eyes.new
    eyes.api_key = Default.static_info['applitool']['apikey']
    eyes.force_full_page_screenshot = true
    eyes.hide_scrollbars = true
    eyes.match_level = match_level
    eyes.stitch_mode = :css
  end

  def action
    return eyes
  end

  def open driver, test_name, width, height
    eyes.open(driver: driver, app_name: 'NCSA WWW', test_name: test_name,
              viewport_size: { width: width, height: height })
  end

  def screenshot pic_name
    eyes.check_window pic_name
  end

  def check_ignore pic_name, elements = []
    window = Applitools::Selenium::Target.window
    elements.each do |e|
      @target = window.ignore(e)
    end

    eyes.check pic_name, @target
  end
end
