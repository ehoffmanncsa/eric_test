require_relative '../../test/test_helper'

# Common actions that UI tests perform
module UIActions
  def self.setup(browser)
    @browser = browser
    @config = Default.env_config
  end

  def self.wait_for_spinner
    Watir::Wait.while(timeout: 120) { @browser.element(:class, 'fa-spinner').present? }
    sleep 1
  end

  def self.wait_for_modal
    Watir::Wait.while { @browser.element(:class, 'modal-content').present? }
    sleep 1
  end

  def self.fasttrack_login
    @browser.goto @config['fasttrack']['login_page']

    @browser.text_field(:id, 'username').set @config['fasttrack']['admin_username']
    @browser.text_field(:id, 'password').set @config['fasttrack']['admin_password']
    @browser.button(:name, 'submit').click

    @browser.goto @config['fasttrack']['login_page']

    #waiting for the right title
    begin
      Watir::Wait.until { @browser.title.match(/Recruit-Match Home/) }
    rescue => e
      puts e; @browser.close
    end
  end

  def self.user_login(email_addr, password = nil)
    password ||= 'ncsa1333' #set this to ncsa to create and eric to run the scripts

    @browser.goto @config['clientrms']['login_page']
    @browser.text_field(:id, 'user_account_login').set email_addr
    @browser.text_field(:id, 'user_account_password').set password
    @browser.button(:name, 'commit').click; sleep 15
  end

  def self.ted_login(username = nil, password = nil)
    username = username.nil? ? @config['ted']['prem_username'] : username
    password = password.nil? ? @config['ted']['prem_password'] : password

    @browser.goto(@config['ted']['base_url'] + '/sign_in')
    @browser.text_field(:id, 'email').set username
    @browser.text_field(:id, 'password').set password
    @browser.button(:text, 'Sign In').click; sleep 0.5
    wait_for_spinner
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

    subfooter_msg = subfooter.find_element(:class, cls)
    raise "#{viewport_size} - subfooter message not found" unless subfooter_msg.displayed?
    raise "#{viewport_size} - wrong subfooter phone number" unless subfooter_msg.text.include? phone_number
  end

  def self.clear_cookies
    @browser.cookies.clear
  end

  def self.coach_rms_login(username = nil, password = nil)
    @browser.goto @config['coach_rms']['login_page']

    username = username.nil? ? @config['coach_rms']['username'] : username
    password = password.nil? ? @config['coach_rms']['password'] : password
    @browser.text_field(:id, 'j_username').set username
    @browser.text_field(:id, 'j_password').set password
    @browser.button(:name, '_submit').click
  end

  def self.coach_live_login(username = nil, password = nil)
    @browser.goto @config['coach_live']['login_page']

    username = username.nil? ? @config['coach_live']['username'] : username
    password = password.nil? ? @config['coach_live']['password'] : password
    @browser.text_field(:name, 'email').set username
    @browser.text_field(:name, 'password').set password
    @browser.button(:name, 'Log In').click
  end

  def self.goto_edit_profile
    @browser.link(:text, 'Edit Profile').click
  end

  def self.goto_ncsa_university
    @browser.link(:text, 'NCSA University').click
  end
end
