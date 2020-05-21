# encoding: utf-8
require_relative '../../test/test_helper'

# This helper is to help in performing TED related actions
module TED
  def self.setup(ui_object)
    @browser = ui_object
    UIActions.setup(@browser)
    @api = Api.new
    @base_url = Default.env_config['ted']['base_url']

    @gmail = GmailCalls.new
    @gmail.get_connection
  end

  def self.navbar
    UIActions.find_by_test_id('navbar')
  end

  def self.sidebar
    @browser.element(class: 'sidebar')
  end

  def self.modal
    @browser.element(class: 'modal-content')
  end

  def self.goto_activity
    # this shows all the athletes' activity
    Watir::Wait.until { navbar.present? }
    go_to_endpoint "activity"
    UIActions.wait_for_spinner; sleep 1
  end

  def self.goto_roster
    # this shows all the teams
    Watir::Wait.until { navbar.present? }
    navbar.link(text: 'Roster').click
    UIActions.wait_for_spinner; sleep 1
  end

  def self.goto_account_settings
    # only coach admin and PA see this
    UIActions.find_by_test_id("user-menu").click
    UIActions.find_by_test_id("user-menu-account-settings").click
    UIActions.wait_for_spinner
  end

  def self.goto_colleges
    # where user perform colleges search
    navbar.link(text: 'Colleges').click
    UIActions.wait_for_spinner
    sleep 1.5
  end

  def self.open_college_filters
    # filter will default as open if org has no college data
    return unless @browser.element(class: 'filter-results').element(class: 'fa-chevron-down').present?

    @browser.button(text: 'Define Search').click
  end

  def self.go_to_athlete_tab
    # go to Roster Management -> athlete
    @browser.refresh; sleep 1
    goto_roster
    @browser.link(text: 'Athletes').click; sleep 2
  end

  def self.go_to_team_tab
    # go to Roster Management -> athlete
    @browser.refresh; sleep 1
    goto_roster
    @browser.link(text: 'Teams').click
  end

  def self.go_to_staff_tab
    # go to Roster Management -> staff
    @browser.refresh; sleep 1
    goto_roster
    @browser.link(text: 'Staff').click; sleep 1
  end

  def self.go_to_payment_method_tab
    # go to Account Settings -> payment methods
    @browser.refresh; sleep 1
    goto_account_settings
    @browser.link(text: 'Payment Methods').click
  end

  def self.go_to_organization_tab
    # go to Account Settings -> Organization
    @browser.refresh; sleep 1
    goto_account_settings
    @browser.link(text: 'Organization').click
  end

  def self.go_to_athlete_evaluation(athlete_id)
    go_to_endpoint "athletes/#{athlete_id}"
    @browser.link(text: 'Athlete Evaluation').click
  end

  def self.go_to_endpoint(endpoint)
    @browser.goto "#{@base_url}#{endpoint}"
  end

  def self.sign_out
    UIActions.find_by_test_id("user-menu").click; sleep 1
    @browser.div(class: 'dropdown-menu__menu').link(text: 'Sign Out').click
    sleep 1
  end

  def self.end_imperson
    sidebar.link(text: 'End Impersonation').click; sleep 1
  end

  def self.get_row_by_name(name)
    if !(@browser.html.include? name)
      temp = name.split(' ')
      temp.each { |word| word.capitalize! }
      name = temp.join(' ')
    end

    @browser.element(text: name).parent
  end

  def self.get_athlete_status(name = nil)
    go_to_athlete_tab

    row = get_row_by_name(name)
    row.elements(tag_name: 'td')[4].text # this is status
  end

  def self.delete_athlete(name)
    row = TED.get_row_by_name(name)
    cog = row.elements(tag_name: 'td').last.element(class: 'fa-cog')
    cog.click

    Watir::Wait.until { modal.present? }

    modal.button(text: 'Delete').click
    small_modal = modal.div(class: 'modal-content')
    small_modal.button(text: 'Delete').click

    UIActions.wait_for_modal
  end

  def self.impersonate_org(org_id = nil)
    partner_username = Default.env_config['ted']['partner_username']
    partner_password = Default.env_config['ted']['partner_password']

    UIActions.ted_login(partner_username, partner_password)

    # default to Awesome Sauce
    org_id = '728' if org_id.nil?
    url = Default.env_config['ted']['base_url'] + "organizations/#{org_id}"

    @browser.goto url
    UIActions.wait_for_spinner

    @browser.link(text: 'Enter Org as Coach').click
    UIActions.wait_for_spinner
  end

  def self.impersonate
    @browser.link(text: 'Enter Org as Coach').click
    UIActions.wait_for_spinner
  end

  def self.add_payment
    # open add payment method modal
    @browser.button(text: 'Add Payment Method').click
  end

  def self.fill_out_form
    first_name = MakeRandom.first_name
    last_name = MakeRandom.last_name

    inputs = TED.modal.elements(tag_name: 'input')
    inputs[0].send_keys first_name
    inputs[1].send_keys last_name
    inputs[2].send_keys '4242424242424242'
    inputs[3].send_keys '123'
    inputs[4].send_keys MakeRandom.number(5)
    inputs[5].send_keys MakeRandom.email

    # also return name for assertion
    @full_name = "#{first_name} #{last_name}"
  end

  def self.select_dropdowns
    lists = TED.modal.select_lists(class: 'form-control')
    lists.each do |list|
      options = list.options.to_a
      options.shift
      list.select options.sample.text
    end

    TED.modal.button(text: 'Submit').click; sleep 3
  end

  def self.check_accepted_email
    @gmail.mail_box = 'TED_Accepted_Request'
    emails = @gmail.get_unread_emails

    @gmail.delete(emails) unless emails.empty?
  end

  def self.check_welcome_email
    @gmail.mail_box = 'TED_Welcome'
    emails = @gmail.get_unread_emails

    @gmail.delete(emails) unless emails.empty?
  end

  def self.check_invite_email
    @gmail.mail_box = 'TED_Athlete_invite_email'
    emails = @gmail.get_unread_emails
    @gmail.delete(emails) unless emails.empty?
  end

  def self.set_new_password_coach
    Watir::Wait.until {  TED.modal.present? }
    assert TED.modal, 'Set new password modal not found'

    inputs = TED.modal.elements(:tag_name, 'input').to_a
    inputs[0].send_keys 'ncsa'
    inputs[1].send_keys 'ncsa'
    TED.modal.element(:tag_name, 'button').click

    UIActions.wait_for_modal
  end
end
