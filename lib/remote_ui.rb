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
end
