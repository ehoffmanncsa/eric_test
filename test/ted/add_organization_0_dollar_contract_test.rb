# encoding: utf-8
require_relative '../test_helper'

# TS-351: TED Regression
# UI Test: Adding an Organization With a $0 Contract

=begin
  PA Otto Mation
  Gmail ncsa.automation@gmail.com, mailbox TED_Contract
  PA add new organization via UI, this org is Verified
  Then create a new contract for this org with 100% discount
  This results in $0 value contract
  Coach admin sign TOS and authorize Credit Card
  Make sure there is popup to change password for coach
  UI will stall here while test goes and
  make sure all the associated emails are received then delete them
=end

class AddOrg0DollarContractTest < Common
  def setup
    super
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Contract'
    @gmail.sender = 'TeamEdition@ncsasports.org'

    @partner_username = Default.env_config['ted']['partner_username']
    @partner_password = Default.env_config['ted']['partner_password']

    @org_name = MakeRandom.name
    @zipcode = MakeRandom.number(5)
    @first_name = MakeRandom.name
    @last_name = MakeRandom.name
    @email = MakeRandom.email
    @phone = MakeRandom.number(10)
  end

  def teardown
    super
  end

  def add_organization
    UIActions.ted_login(@partner_username, @partner_password)
    Watir::Wait.until { TED.sidebar.visible? }
    UIActions.wait_for_spinner

    # open add modal and make sure it shows up
    @browser.button(:text, 'Add Organization').click
    assert TED.modal, 'Add modal not found'

    # select club
    list = TED.modal.select_list(:class, 'form-control')
    list.select 'Club'; sleep 1

    # fill out club info
    inputs = TED.modal.elements(:tag_name, 'input').to_a
    inputs[0].send_keys @org_name
    inputs[3].send_keys 'IL'
    inputs[4].send_keys @zipcode
    inputs[5].send_keys @first_name
    inputs[6].send_keys @last_name
    inputs[7].send_keys @email
    inputs[8].send_keys @phone

    # select info from dropdowns in modal
    lists = TED.modal.select_lists(:class, 'form-control')
    lists[0].select 'US'; sleep 1
    lists[2].options.to_a.sample.select
    TED.modal.button(:text, 'Add').click; sleep 1
  end

  def add_contract
    # open add contract modal
    @browser.button(:text, 'Create New Contract').click

    # fill out form
    sports = TED.modal.select_list(:name, 'sportType').options.to_a
    pay_counts = TED.modal.select_list(:name, 'numberOfPayments').options.to_a
    sports.shift; sports.sample.select
    pay_counts.shift; pay_counts.sample.select

    team_counts = TED.modal.text_field(:name, 'numberOfTeams')
    start_date = TED.modal.element(:name, 'startDate')
    first_pay = TED.modal.element(:name, 'firstPaymentDate')
    discount = TED.modal.text_field(:name, 'discount')
    discount_note = TED.modal.text_field(:name, 'discountNote')
    team_counts.set rand(1 .. 99)

    date = Time.now.strftime("%Y-%m-%d")
    text = "arguments[0].type='text'"
    TED.modal.execute_script(text, start_date)
    TED.modal.execute_script(text, first_pay)
    start_date.send_keys date
    first_pay.send_keys date

    discount.set 100
    discount_note.set '0 Dollar Contract'

    # make sure all payments are 0
    table = TED.modal.table(:class, 'table')
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

    TED.modal.button(:text, 'Submit').click; sleep 0.5
  end

  def get_sign_page_url_in_email
    keyword = 'https://team-staging.ncsasports.org/terms_of_service?'
    emails = @gmail.get_unread_emails
    msg = @gmail.parse_body(emails.last, keyword)
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

    org = @browser.element(:text, @org_name).parent
    org.click

    # make sure show page has right org name
    Watir::Wait.until { @browser.div(:class, 'college-details').present? }
    details = @browser.div(:class, 'college-details')
    assert (details.html.include? @org_name), 'Show page doesnt have right org name'

    add_contract
    @browser.refresh; sleep 1

    # make sure contract shows up after added
    exist_contracts = @browser.div(:class, 'existing-contract')
    contracts = exist_contracts.elements(:tag_name, 'li')
    refute_empty contracts, 'No contracts found'

    # send invoice email and signout of PA
    contracts[0].element(:class, 'drawer-toggle').click
    contracts[0].element(:class, 'fa-envelope-o').click
    TED.sign_out

    goto_sign_page_via_url_in_email
    @browser.text_field(:placeholder, 'Signature').set @org_name; sleep 0.5
    @browser.button(:text, 'I Accept').click
    @browser.button(:text, 'Accept').click

    # make sure coach is in dashboard page and change password modal prompts
    Watir::Wait.until { TED.modal.present? }
    assert TED.modal, 'Set new password modal not found'

    # check email by subject and delete it afterward
    signed_confirm = "#{@org_name} has signed Terms of Service and authorized credit card"
    signed_receipt = 'Team Edition Signed Contract Receipt'
    intro_to_team = 'Introduction to Team Edition'
    [signed_confirm, signed_receipt, intro_to_team].each { |subject| check_email(subject) }
  end
end
