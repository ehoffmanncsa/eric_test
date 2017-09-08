# encoding: utf-8
require 'selenium-webdriver'

class LocalUI
  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @driver
  end

  def goto(url)
    @driver.get url
    @driver
  end

  def resize(width, height)
    @driver.manage.window.resize_to(width, height)
    @driver
  end

  def close
    @driver.quit
  end
end
