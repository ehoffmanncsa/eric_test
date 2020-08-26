require_relative '../../test/test_helper'

# Common actions that UI tests perform
module UIActions
  def self.setup(browser)
    @browser = browser
    @config = Default.env_config
  end

  def self.wait_for_spinner
    Watir::Wait.while(timeout: 120) { @browser.element(class: 'fa-spinner').present? }
    sleep 1
  end

  def self.wait_for_modal
    Watir::Wait.while { @browser.element(class: 'modal-content').present? }
    sleep 1
  end

  def self.fasttrack_login(username = nil, password = nil)
    username ||= @config['fasttrack']['admin_username']
    password ||= @config['fasttrack']['admin_password']

    @browser.goto(@config['fasttrack']['base_url'] + @config['fasttrack']['login_page'])
    @browser.text_field(id: 'username').set username
    @browser.text_field(id: 'password').set password
    @browser.button(name: 'submit').click

    sleep 3

    #waiting for the right title
    begin
      Watir::Wait.until { @browser.title.match(/Recruit-Match Home/) }
    rescue => e
      puts e; @browser.close
    end
  end

  def self.user_login(email_addr, password = nil)
    password ||= 'ncsa'

    @browser.goto(@config['clientrms']['base_url'] + @config['clientrms']['login_page'])
    @browser.text_field(id: 'user_account_login').set email_addr
    @browser.text_field(id: 'user_account_password').set password
    @browser.button(name: 'commit').click; sleep 1

    # waiting for the right page title
    begin
      sleep 2
      Watir::Wait.until { !@browser.title.match(/Student-Athlete Sign In/) }
    rescue => e
      puts e; @browser.close
    end

    privacy_modal_button = @browser.element(class: 'privacy-policy-modal__cta-button')
    privacy_modal_button.click if privacy_modal_button.exists?
    sleep 3
  end

  def self.ted_login(username = nil, password = nil)
    username = username.nil? ? @config['ted']['prem_username'] : username
    password = password.nil? ? @config['ted']['prem_password'] : password

    @browser.goto(@config['ted']['base_url'] + 'sign_in')
    @browser.text_field(id: 'email').set username
    @browser.text_field(id: 'password').set password
    @browser.button(text: 'Sign In').click; sleep 0.5
    wait_for_spinner
  end

  def self.get_subfooter
    @browser.find_element(class: 'subfooter')
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

    subfooter_msg = subfooter.find_element(class: cls)
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

    @browser.text_field(id: 'j_username').set username
    @browser.text_field(id: 'j_password').set password

    @browser.button(name: '_submit').click
  end

  def self.goto_dashboard
    url = @config['clientrms']['base_url'] + 'dashboard/show'
    @browser.goto url
  end

  def self.goto_edit_profile
    url = @config['clientrms']['base_url'] + 'profile/profile_summary/edit'
    @browser.goto url
  end

  def self.goto_ncsa_university
    @browser.link(text: 'NCSA University').click
  end

  def self.goto_my_information
    url = @config['clientrms']['base_url'] + @config['clientrms']['my_information']
    @browser.goto url
  end

  def self.goto_academics
    # go to academics
    url = @config['clientrms']['base_url'] + @config['clientrms']['academic']
    @browser.goto url
  end

  def self.goto_key_stats
    # go to key stats
    url = @config['clientrms']['base_url'] + @config['clientrms']['physical_measurables']
    @browser.goto url
  end

  def self.find_by_test_id(test_id)
    @browser.element("data-test-id" => test_id)
  end
end
