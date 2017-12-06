require_relative '../../test/test_helper'

# Common actions that UI tests perform
module UIActions
  def self.setup(driver)
    @driver = driver
    @config = YAML.load_file('config/config.yml')
    @creds = YAML.load_file('config/.creds.yml')
    sleep 1
  end

  def self.wait(timeout = nil)
    timeout.nil? ? timeout = 15 : timeout
    Selenium::WebDriver::Wait.new(timeout: timeout)
  end

  def self.fasttrack_login
    @driver.get @config['pages']['fasttrack_login']

    @driver.find_element(:id, 'username').send_keys @creds['fasttrack_admin']['username']
    @driver.find_element(:id, 'password').send_keys @creds['fasttrack_admin']['password']
    @driver.find_element(:name, 'submit').click

    @driver.get @config['pages']['fasttrack_login']

    #waiting for the right title
    begin
      wait.until { @driver.title.match(/Recruit-Match Home/) }
    rescue => e
      puts e; @driver.close
    end
  end

  def self.user_login(email_addr, pwd = nil)
    password = pwd ? pwd : 'ncsa'
    @driver.get @config['pages']['user_login']

    @driver.find_element(:id, 'user_account_login').send_keys email_addr
    @driver.find_element(:id, 'user_account_password').send_keys password
    @driver.find_element(:name, 'commit').click

    #waiting for the right title
    begin
      wait.until { !@driver.title.match(/Student-Athlete Sign In/) }
    rescue => e
      puts e; @driver.close
    end
  end

  def self.coach_login(username = nil, password = nil)
    @driver.get @config['TED_coach_app']['login_staging']

    username = username.nil? ? @creds['ted']['username'] : username
    password = password.nil? ? @creds['ted']['password'] : password
    @driver.find_elements(:tag_name, 'input')[0].send_keys username
    @driver.find_elements(:tag_name, 'input')[1].send_keys password
    @driver.find_element(:tag_name, 'button').click; sleep 1
  end

  def self.get_subfooter
    @driver.find_element(:class, 'subfooter')
  end

  def self.check_subfooter_msg(subfooter, viewport_size)
    cls = ''; phone_number = ''; failure = []
    case viewport_size
      when 'iphone'
        phone_number = '855-410-6272'
        cls = 'tablet-hide'
      else
        phone_number = '866-495-5172'
        cls = 'tablet-show'
    end

    subfooter_msg = subfooter.find_element(:class, cls)
    raise "#{viewport_size} - subfooter message not found" unless subfooter_msg.displayed?
    raise "#{viewport_size} - wrong subfooter phone number" unless subfooter_msg.text.include? phone_number
  end

  def self.clear_cookies
    @driver.manage.delete_all_cookies
  end
end
