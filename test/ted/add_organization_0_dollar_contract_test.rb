# encoding: utf-8
require_relative '../test_helper'

# TS-351: TED Regression
# UI Test: Adding an Organization With a $0 Contract
# Creating a new organization as a partner admin
# This organization and its primary contact (1st coach)
# are Verified by default
class AddOrg0DollarContractTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Contract'
    @gmail.sender = 'TeamEdition@ncsasports.org'

    creds = YAML.load_file('config/.creds.yml')
    @admin_username = creds['ted_admin']['username']
    @admin_password = creds['ted_admin']['password']

    @org_name = MakeRandom.name
    @zipcode = MakeRandom.number(5)
    @first_name = MakeRandom.name
    @last_name = MakeRandom.name
    @email = MakeRandom.email
    @phone = MakeRandom.number(10)
  end

  def teardown
    @browser.close
  end

  def modal
    @browser.div(:class, 'modal-content')
  end

  def add_organization
    UIActions.ted_login(@admin_username, @admin_password)
    Watir::Wait.until { @browser.element(:id, 'react-tabs-1').visible? }
    Watir::Wait.until { @browser.elements(:class, 'cards')[0].visible? }

    # open add modal and make sure it shows up
    @browser.button(:text, 'Add Organization').click
    assert @browser.div(:class, 'modal-content'), 'Add modal not found'

    # select club
    list = modal.select_list(:class, 'form-control')
    list.select 'Club'; sleep 1

    # fill out club info
    inputs = modal.elements(:tag_name, 'input').to_a
    inputs[0].send_keys @org_name
    inputs[3].send_keys 'IL'
    inputs[4].send_keys @zipcode
    inputs[5].send_keys @first_name
    inputs[6].send_keys @last_name
    inputs[7].send_keys @email
    inputs[8].send_keys @phone

    # select info from dropdowns in modal
    lists = modal.select_lists(:class, 'form-control')
    lists[0].select 'US'; sleep 1
    lists[2].options.to_a.sample.select
    modal.button(:text, 'Add').click; sleep 1
  end

  def add_contract
    # open add contract modal
    @browser.button(:text, 'Create New Contract').click

    # fill out form
    sports = modal.select_list(:name, 'sportType').options.to_a
    pay_counts = modal.select_list(:name, 'numberOfPayments').options.to_a
    sports.shift; sports.sample.select
    pay_counts.shift; pay_counts.sample.select

    team_counts = modal.text_field(:name, 'numberOfTeams')
    start_date = modal.text_field(:name, 'startDate')
    first_pay = modal.text_field(:name, 'firstPaymentDate')
    discount = modal.text_field(:name, 'discount')
    discount_note = modal.text_field(:name, 'discountNote')
    team_counts.set rand(1 .. 99)

    date = Time.now.strftime("%m/%d/%Y")
    text = "arguments[0].type='text'"
    modal.execute_script(text, start_date)
    modal.execute_script(text, first_pay)
    start_date.set date
    first_pay.set date

    discount.set 100
    discount_note.set '0 Dollar Contract'

    # make sure all payments are 0
    table = modal.table(:class, 'table')
    rows = table.rows.to_a; rows.shift

    failure = []
    i = 0
    rows.each do |r|
      price = r.cells.last.text.gsub('$', '').to_f
      msg = "Payment #{i} is #{price} - expect 0.00"
      failure << msg unless price.eql? 0.00
      i += 1
    end
    assert_empty failure

    modal.button(:text, 'Submit').click; sleep 4
  end

  def get_sign_page_url_in_email
    keyword = 'https://team-staging.ncsasports.org/terms_of_service?'
    emails = @gmail.get_unread_emails
    msg = @gmail.parse_body(emails, keyword)
    url = msg[1].split("\"")[1]
    @gmail.delete(emails)

    url
  end

  def goto_sign_page_via_url_in_email
    url = get_sign_page_url_in_email
    @browser.goto url
  end

  def check_email(subject)
    @gmail.mail_box = 'Inbox'
    @gmail.subject = subject
    emails = @gmail.get_unread_emails
    refute_empty emails, 'No Signed confirm email received'

    @gmail.delete(emails)
  end

  def test_add_organization_0_dollar_contract
    add_organization

    # find the Verified section
    board = @browser.elements(:class, 'cards')[0]
    verified_section = board.elements(:class, 'col-sm-12')[5]
    msg = 'This is not Verified section'
    assert_equal verified_section.element(:class, 'section-heading').text, 'Verified', msg

    # find new added org in Verified section by id and open show page
    id = TED.get_org_id(@email)
    verified_section.elements(:tag_name, 'a').each do |e|
      if e.attribute_value('href').eql? "https://team-staging.ncsasports.org/organizations/#{id}"
        @new_org = e; break
      end
    end
    refute_nil @new_org, "Cannot find new organization id #{id}"
    @new_org.click

    # make sure show page has right org name
    Watir::Wait.until { @browser.div(:class, 'college-details').present? }
    details = @browser.div(:class, 'college-details')
    assert (details.html.include? @org_name), 'Show page doesnt have right org name'

    add_contract

    # make sure contract shows up after added
    exist_contracts = @browser.div(:class, 'existing-contract')
    contracts = exist_contracts.elements(:tag_name, 'li')
    refute_empty contracts, 'No contracts found'

    # send invoice email and signout of PA
    contracts[0].element(:class, 'drawer-toggle').click
    contracts[0].element(:class, 'fa-envelope-o').click
    TED.sign_out

    goto_sign_page_via_url_in_email
    @browser.text_field(:placeholder, 'Signature').set @first_name
    @browser.button(:text, 'I Accept').click
    @browser.button(:text, 'Accept').click

    # make sure coach is in dashboard page and change password modal prompts
    Watir::Wait.until { @browser.element(:class, 'modal-content').present? }
    modal = @browser.element(:class, 'modal-content')
    assert modal, 'Set new password modal not found'

    # check email by subject and delete it afterward
    signed_confirm = "#{@org_name} has signed Terms of Service and authorized credit card"
    signed_receipt = 'Team Edition Signed Contract Receipt'
    intro_to_team = 'Introduction to Team Edition'
    [signed_confirm, signed_receipt, intro_to_team].each { |subject| check_email(subject) }
  end
end
