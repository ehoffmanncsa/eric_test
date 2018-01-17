require_relative '../../test/test_helper'

# Common actions that UI tests perform
module UIActions
  def self.setup(browser)
    @browser = browser
    @config = YAML.load_file('config/config.yml')
    @creds = YAML.load_file('config/.creds.yml')
  end

  def self.fasttrack_login
    @browser.goto @config['pages']['fasttrack_login']

    @browser.text_field(:id, 'username').set @creds['fasttrack_admin']['username']
    @browser.text_field(:id, 'password').set @creds['fasttrack_admin']['password']
    @browser.button(:name, 'submit').click

    @browser.goto @config['pages']['fasttrack_login']

    #waiting for the right title
    begin
      Watir::Wait.until { @browser.title.match(/Recruit-Match Home/) }
    rescue => e
      puts e; @browser.close
    end
  end

  def self.user_login(email_addr, pwd = nil)
    password = pwd ? pwd : 'ncsa'
    @browser.goto @config['pages']['user_login']

    @browser.text_field(:id, 'user_account_login').set email_addr
    @browser.text_field(:id, 'user_account_password').set password
    @browser.button(:name, 'commit').click

    #waiting for the right title
    begin
      Watir::Wait.until { !@browser.title.match(/Student-Athlete Sign In/) }
    rescue => e
      puts e; @browser.close
    end
  end

  def self.ted_coach_login(username = nil, password = nil)
    @browser.goto @config['TED_coach_app']['login_staging']

    username = username.nil? ? @creds['ted_coach']['username'] : username
    password = password.nil? ? @creds['ted_coach']['password'] : password
    text_fields = @browser.elements(:tag_name, 'input').to_a
    text_fields[0].set username
    text_fields[1].set password
    @browser.button(:tag_name, 'button').click
  end

  def self.get_subfooter
    @browser.find_element(:class, 'subfooter')
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

    subfooter_msg = subfooter.element(:class, cls)
    raise "#{viewport_size} - subfooter message not found" unless subfooter_msg.displayed?
    raise "#{viewport_size} - wrong subfooter phone number" unless subfooter_msg.text.include? phone_number
  end

  def self.clear_cookies
    @browser.cookies.clear
  end

  def self.coach_rms_login(username = nil, password = nil)
    @browser.goto @config['pages']['coach_rms_login']

    username = username.nil? ? @creds['coach_rms']['username'] : username
    password = password.nil? ? @creds['coach_rms']['password'] : password
    @browser.text_field(:id, 'j_username').set username
    @browser.text_field(:id, 'j_password').set password
    @browser.button(:name, '_submit').click
  end

  def self.goto_edit_profile
    @browser.link(:text, 'Edit Profile').click
  end

  def self.goto_ncsa_university
    @browser.link(:text, 'NCSA University').click
  end
end
