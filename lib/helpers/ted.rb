# encoding: utf-8
require_relative '../../test/test_helper'

# This helper is to help in performing TED related actions
module TED
  def self.setup(ui_object)
    @browser = ui_object
    UIActions.setup(@browser)
    @api = Api.new
  end

  def self.sidebar
    @browser.element(:class, 'sidebar')
  end

  def self.goto_roster
    # this shows all the teams
    sidebar.link(:text, 'Roster Management').click
    UIActions.wait_for_spinner
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
    @browser.link(:text, 'Staff').click
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

  def self.get_row_by_name(table, name)
    if !(@browser.html.include? name)
      temp = name.split(' ')
      temp.each { |word| word.capitalize! }
      name = temp.join(' ')
    end

    table.element(:text, name).parent
  end

  def self.get_athlete_status(table, name = nil)
    go_to_athlete_tab
    row = get_row_by_name(table, name)
    row.elements(:tag_name, 'td')[4].text # this is status
  end

  def self.delete_athlete(table, name)
    row = TED.get_row_by_name(table, name)
    cog = row.elements(:tag_name, 'td').last.element(:class, 'fa-cog')
    cog.click; sleep 1
    modal = @browser.div(:class, 'modal-content')
    modal.button(:text, 'Delete').click
    small_modal = modal.div(:class, 'modal-content')
    small_modal.button(:text, 'Delete').click
    UIActions.wait_for_modal
  end

  def self.get_org_id(prime_email)
    # using Otto Mation admin token
    header = { 'Session-Token' => TEDAuth.new('admin').get_token }
    url = 'https://qa.ncsasports.org/api/team_edition/partners/1/organizations'
    resp_code, resp = @api.pget(url, header)
    msg = "[ERROR] #{resp_code} GET api/team_edition/partners/1/organizations"
    raise msg unless resp_code.eql? 200

    data = resp['data']
    org = data.detect { |d| d['attributes']['email'].eql? prime_email }

    org['id']
  end

  def self.impersonate_org(org_id = nil)
    creds = YAML.load_file('config/.creds.yml')
    admin_username = creds['ted_admin']['username']
    admin_password = creds['ted_admin']['password']
    UIActions.ted_login(admin_username, admin_password)

    # default to Awesome Sauce
    org_id = '440' if org_id.nil?
    url = "https://team-staging.ncsasports.org/organizations/#{org_id}"
    @browser.goto url; sleep 1
    @browser.link(:text, 'Enter Org as Coach').click; sleep 3
  end
end
