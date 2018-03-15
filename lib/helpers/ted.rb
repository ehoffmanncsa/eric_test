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

  def self.goto_organization
    sidebar.link(:text, 'Organization').click
    Watir::Wait.until { @browser.element(:id, 'react-tabs-1').present? }
  end

  def self.go_to_athlete_tab
    # go to Organization -> athlete
    @browser.refresh; sleep 1
    goto_organization
    @browser.element(:id, 'react-tabs-2').click; sleep 3
    Watir::Wait.until { @browser.element(:id, 'react-tabs-3').visible? }; sleep 1
    Watir::Wait.until { @browser.table(:class, 'table--administration').present? }
  end

  def self.go_to_staff_tab
    # go to Organization -> staff
    @browser.refresh; sleep 1
    goto_organization
    @browser.element(:id, 'react-tabs-4').click; sleep 3
    Watir::Wait.until { @browser.element(:id, 'react-tabs-5').visible? }
  end

  def self.go_to_details_tab
    # go to Organization -> details
    @browser.refresh; sleep 1
    goto_organization
    @browser.element(:id, 'react-tabs-6').click; sleep 3
    Watir::Wait.until { @browser.element(:id, 'react-tabs-7').visible? }
  end

  def self.go_to_payment_method_tab
    # go to Organization -> payment methods
    @browser.refresh; sleep 1
    goto_organization
    @browser.element(:id, 'react-tabs-8').click; sleep 3
    Watir::Wait.until { @browser.element(:id, 'react-tabs-9').visible? }
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
    small_modal.button(:text, 'Delete').click; sleep 1
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

  def self.get_coach_id(coach_email)
    # using awesome volleyball org id 15, coach admin courtney token
    header = { 'Session-Token' => TEDAuth.new('coach').get_token }
    url = 'https://qa.ncsasports.org/api/team_edition/organizations/15/coaches'
    resp_code, resp = @api.pget(url, header)
    msg = "[ERROR] #{resp_code} GET api/team_edition/organizations/15/coaches"
    raise msg unless resp_code.eql? 200

    data = resp['data']
    coach = data.detect { |d| d['attributes']['email'].eql? coach_email }

    coach['id']
  end

  def self.impersonate_org(org_id = nil)
    creds = YAML.load_file('config/.creds.yml')
    admin_username = creds['ted_admin']['username']
    admin_password = creds['ted_admin']['password']
    UIActions.ted_login(admin_username, admin_password)

    url = "https://team-staging.ncsasports.org/organizations/#{org_id}"
    @browser.goto url; sleep 1
    @browser.link(:text, 'Enter Org as Coach').click; sleep 3
  end
end
