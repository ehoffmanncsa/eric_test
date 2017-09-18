# encoding: utf-8
require 'selenium-webdriver'

class RemoteUI

  attr_accessor :driver

  def initialize browser
    # Input capabilities
    caps = Selenium::WebDriver::Remote::Capabilities.new
    caps['browser'] = browser
    caps['resolution'] = '1600x1200'

    case browser
      when 'IE'
        caps['os'] = 'Windows'
        caps['os_version'] = '10'
        caps['browser_version'] = '11.0'
      when 'Edge'
        caps['os'] = 'Windows'
        caps['os_version'] = '10'
      else
        caps['os'] = 'OS X'
        caps['os_version'] = 'Sierra'
    end

    caps['browserstack.debug'] = true
    caps['browserstack.networkLogs'] = true

    self.driver = Selenium::WebDriver.for(
      :remote,
      url: 'http://tiffanyrea1:H6g4QMJ4wQwoWRwEuesF@hub-cloud.browserstack.com/wd/hub',
      desired_capabilities: caps)
  end

  # def action
  #   return self.driver
  # end

  # def goto url
  #   self.driver.navigate.to url
  # end

  # def wait_for seconds
  #   self.driver.manage.timeouts.implicit_wait = seconds
  # end

  # def resize_to width, height
  #   self.driver.manage.window.resize_to(width, height)
  # end

  # def admin_login username, password
  #   page = self.driver.goto('http://qa.ncsasports.org/ncsa-cas/login?' \
  #            'service=https%3A%2F%2Fqa.ncsasports.org%2F' \
  #            'fasttrack%2Fj_spring_cas_security_check')

  #   page.find_element(id: 'username').send_key username
  #   page.find_element(id: 'password').send_key password
  #   page.find_element(name: 'submit').click
  #   raise '[ERROR] Cannot find fasttrack login page' unless @page.title =~ /Login/

  #   return page
  # end

  # def close
  #   self.driver.quit
  # end
end
