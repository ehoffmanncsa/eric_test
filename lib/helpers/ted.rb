# encoding: utf-8
require_relative '../../test/test_helper'

# This helper is to help in performing TED related actions
module TED
  def self.setup(ui_object)
    @browser = ui_object
    UIActions.setup(@browser)
    @api = Api.new

    @gmail = GmailCalls.new
    @gmail.get_connection
  end

  def self.sidebar
    @browser.element(:class, 'sidebar')
  end

  def self.modal
    @browser.element(:class, 'modal-content')
  end

  def self.goto_roster
    # this shows all the teams
    Watir::Wait.until { sidebar.present? }
    sidebar.link(:text, 'Roster Management').click
    UIActions.wait_for_spinner; sleep 1
  end

  def self.goto_account_settings
    # only coach admin and PA see this
    sidebar.link(:text, 'Account Settings').click
    UIActions.wait_for_spinner
  end

  def self.goto_colleges
    # where user perform colleges search
    sidebar.link(:text, 'Colleges').click
    UIActions.wait_for_spinner
    sleep 1.5
  end

  def self.open_college_filters
    # filter will default as open if org has no college data
    return unless @browser.element(:class, 'filter-results').element(:class, 'fa-chevron-down').present?

    @browser.button(:text, 'Define Search').click
  end

  def self.go_to_athlete_tab
    # go to Roster Management -> athlete
    @browser.refresh; sleep 1
    goto_roster
    @browser.link(:text, 'Athletes').click; sleep 2
  end

  def self.go_to_team_tab
    # go to Roster Management -> athlete
    @browser.refresh; sleep 1
    goto_roster
    @browser.link(:text, 'Teams').click
  end

  def self.go_to_staff_tab
    # go to Roster Management -> staff
    @browser.refresh; sleep 1
    goto_roster
    @browser.link(:text, 'Staff').click; sleep 1
  end

  def self.go_to_payment_method_tab
    # go to Account Settings -> payment methods
    @browser.refresh; sleep 1
    goto_account_settings
    @browser.link(:text, 'Payment Methods').click
  end

  def self.go_to_organization_tab
    # go to Account Settings -> Organization
    @browser.refresh; sleep 1
    goto_account_settings
    @browser.link(:text, 'Organization').click
  end

  def self.sign_out
    sidebar.link(:text, 'Sign Out').click; sleep 1
  end

  def self.end_imperson
    sidebar.link(:text, 'End Impersonation').click; sleep 1
  end

  def self.get_row_by_name(name)
    if !(@browser.html.include? name)
      temp = name.split(' ')
      temp.each { |word| word.capitalize! }
      name = temp.join(' ')
    end

    @browser.element(:text, name).parent
  end

  def self.get_athlete_status(name = nil)
    go_to_athlete_tab

    row = get_row_by_name(name)
    row.elements(:tag_name, 'td')[4].text # this is status
  end

  def self.delete_athlete(name)
    row = TED.get_row_by_name(name)
    cog = row.elements(:tag_name, 'td').last.element(:class, 'fa-cog')
    cog.click

    Watir::Wait.until { modal.present? }

    modal.button(:text, 'Delete').click
    small_modal = modal.div(:class, 'modal-content')
    small_modal.button(:text, 'Delete').click

    UIActions.wait_for_modal
  end

  def self.impersonate_org(org_id = nil)
    partner_username = Default.env_config['ted']['partner_username']
    partner_password = Default.env_config['ted']['partner_password']

    UIActions.ted_login(partner_username, partner_password)

    # default to Awesome Sauce
    org_id = '440' if org_id.nil?
    url = "https://team-staging.ncsasports.org/organizations/#{org_id}"

    @browser.goto url
    UIActions.wait_for_spinner

    @browser.link(:text, 'Enter Org as Coach').click
    UIActions.wait_for_spinner
  end

  def self.check_accepted_email
    @gmail.mail_box = 'TED_Accepted_Request'
    emails = @gmail.get_unread_emails
    raise 'No accepted email found after athlete accepted invitation' if emails.empty?

    @gmail.delete(emails)
  end

  def self.check_welcome_email
    @gmail.mail_box = 'TED_Welcome'
    emails = @gmail.get_unread_emails
    raise 'No welcome email found after inviting athlete' if emails.empty?

    @gmail.delete(emails)
  end
end
