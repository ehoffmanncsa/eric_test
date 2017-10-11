# encoding: utf-8
require 'selenium-webdriver'

class LocalUI
  attr_accessor :driver
  attr_accessor :wait

  def initialize(gui = nil)
    @config = YAML.load_file('config/config.yml')

    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    self.driver = gui ? (Selenium::WebDriver.for(:firefox)) : (Selenium::WebDriver.for(:chrome, options: options))
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
    begin
      wait.until { driver.title.match(/Recruit-Match Home/) }
    rescue => e
      puts e; driver.close
    end
  end

  def user_login(username)
    driver.get @config['pages']['user_login']

    driver.find_element(:id, 'user_account_login').send_keys username
    driver.find_element(:id, 'user_account_password').send_keys 'ncsa'
    driver.find_element(:name, 'commit').click

    #waiting for the right title
    begin
      wait.until { !driver.title.match(/Student-Athlete Sign In/) }
    rescue => e
      puts e; driver.close
    end
  end
end
