# encoding: utf-8
require 'selenium-webdriver'

class LocalUI
  attr_accessor :driver
  attr_accessor :wait

  def initialize(gui = nil)
    @config = YAML.load_file('config/config.yml')

    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    self.driver = gui ? (Selenium::WebDriver.for(:chrome)) : (Selenium::WebDriver.for(:chrome, options: options))
  end

  def wait(timeout = nil)
    timeout.nil? ? timeout = 15 : timeout
    self.wait = Selenium::WebDriver::Wait.new(timeout: timeout)
  end

  def fasttrack_login
    driver.get @config['pages']['fasttrack_login']

    driver.find_element(:id, 'username').send_keys @config['admin']['username']
    driver.find_element(:id, 'password').send_keys @config['admin']['password']
    driver.find_element(:name, 'submit').click

    driver.get @config['pages']['fasttrack_login']

    #waiting for the right title
    wait.until { driver.title.match(/Recruit-Match Home/) }
  end
end
