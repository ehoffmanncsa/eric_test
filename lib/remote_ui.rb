# encoding: utf-8
require 'selenium-webdriver'
require 'watir'

class RemoteUI
  def initialize
    # Input capabilities
    caps = Selenium::WebDriver::Remote::Capabilities.new
    caps['browser'] = 'chrome'
    caps['browser_version'] = '60.0'
    caps['os'] = 'OS X'
    caps['os_version'] = 'Sierra'
    caps['resolution'] = '1024x768'
    caps['browserstack.debug'] = true
    caps['browserstack.networkLogs'] = true

    @driver = Selenium::WebDriver.for(
      :remote,
      url: "http://ncsadevelopers1:qJE6Y3NPPHD9YEwyp3bs@hub-cloud.browserstack.com/wd/hub",
      desired_capabilities: caps)
  end

  def goto(url)
    @driver.navigate.to url

    @driver
  end

  def admin_login(username, password)
    page = @driver.goto('http://qa.ncsasports.org/ncsa-cas/login?' \
             'service=https%3A%2F%2Fqa.ncsasports.org%2F' \
             'fasttrack%2Fj_spring_cas_security_check')

    page.find_element(id: 'username').send_key username
    page.find_element(id: 'password').send_key password
    page.find_element(name: 'submit').click
    raise '[ERROR] Cannot find fasttrack login page' unless @page.title =~ /Login/

    page
  end

  def close
    @driver.quit
  end
end
