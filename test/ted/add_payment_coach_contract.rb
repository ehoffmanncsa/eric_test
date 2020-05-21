# encoding: utf-8
require_relative '../test_helper'

# Sales-1657: TED Regression
# UI Test: Adding an Organization With a Contract and verify admin and coach
# can add a payment method

=begin
  PA Otto Mation
  Gmail ncsa.automation@gmail.com, mailbox TED_Contract
  PA add new organization via UI, this org is Verified
  Then create a new contract for this org.
  Coach admin sign TOS and authorize Credit Card
  Coach will also add a payment method
  make sure all the associated emails are received then delete them
=end

class AddOrgContractCoachPaymentTest < Common
  def setup
    super
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.sender = 'TeamEdition@ncsasports.org'

    @partner_username = Default.env_config['ted']['partner_username']
    @partner_password = Default.env_config['ted']['partner_password']

    @org_name = MakeRandom.company_name
  end

  def teardown
    super
  end

  def open_form
    @browser.button(text: 'Add Organization').click
    assert TED.modal, 'Add modal not found'

    # select club
    sleep 2 # or else the UI is wiped blank :"(
    list = TED.modal.select_list(class: 'form-control')
    list.select 'Club'; sleep 1
  end

  def fill_out_textfields
    TED.modal.text_field(id: 'name').set @org_name
    TED.modal.text_field(id: 'address').set MakeRandom.address
    TED.modal.text_field(id: 'city').set MakeRandom.city
    TED.modal.text_field(id: 'state').set MakeRandom.state
    TED.modal.text_field(id: 'zipCode').set MakeRandom.zip_code
    TED.modal.text_field(id: 'primaryContactFirstName').set MakeRandom.first_name
    TED.modal.text_field(id: 'primaryContactLastName').set MakeRandom.last_name
    TED.modal.text_field(id: 'email').set MakeRandom.email
    TED.modal.text_field(id: 'phone').set MakeRandom.phone_number
  end

  def select_sports
    TED.modal.select_list(id: 'sportIds').options.to_a.sample.select
  end

  def select_other_dropdowns
    %w[primaryPartnerId country].each do |list_id|
      options = TED.modal.select_list(id: list_id).options.to_a
      options.shift
      options.sample.select; sleep 1
    end
  end

  def add_organization
    UIActions.ted_login(@partner_username, @partner_password)
    Watir::Wait.until { TED.navbar.present? }
    UIActions.wait_for_spinner

    open_form
    fill_out_textfields
    select_sports
    select_other_dropdowns

    TED.modal.button(text: 'Add').click; sleep 1
  end

  def add_contract
    # open add contract modal
    @browser.button(text: 'Create New Contract').click
    sleep 1

    # fill out form
    sports = TED.modal.select_list(name: 'sportType').options.to_a
    pay_counts = TED.modal.select_list(name: 'numberOfPayments').options.to_a
    sports.shift; sports.sample.select
    pay_counts.shift; pay_counts.sample.select

    team_counts = TED.modal.text_field(name: 'numberOfTeams')
    start_date = TED.modal.element(name: 'startDate')
    first_pay = TED.modal.element(name: 'firstPaymentDate')
    team_counts.set rand(1 .. 5)

    date = Time.now.strftime("%Y-%m-%d")
    text = "arguments[0].type='text'"
    TED.modal.execute_script(text, start_date)
    TED.modal.execute_script(text, first_pay)
    start_date.send_keys date
    first_pay.send_keys date

    TED.modal.button(text: 'Submit').click; sleep 0.5
  end

  def get_sign_page_url_in_email
    keyword = '/click?'

    @gmail.mail_box = 'TED_Contract'
    emails = @gmail.get_unread_emails
    msg = @gmail.parse_body(emails.last, keyword).strip!

    url = msg.split("\"")[1]
    @gmail.delete(emails)

    url
  end

  def goto_sign_page_via_url_in_email
    url = get_sign_page_url_in_email
    @browser.goto url
  end

  def check_email(subject = nil)
    @gmail.subject = subject
    emails = @gmail.get_unread_emails
    refute_empty emails, "Email #{subject} not found"

    @gmail.delete(emails)
  end

  def test_add_organization_contract_coach_payment
    add_organization

    org = @browser.element(text: @org_name).parent
    org.click

    # make sure show page has right org name
    Watir::Wait.until { @browser.div(class: 'college-details').present? }
    details = @browser.div(class: 'college-details')
    assert (details.html.include? @org_name), 'Show page doesnt have right org name'

    add_contract
    @browser.refresh; sleep 1

    # make sure contract shows up after added
    exist_contracts = @browser.div(class: 'existing-contract')
    contracts = exist_contracts.elements(:tag_name, 'li')
    refute_empty contracts, 'No contracts found'

    # send invoice email and signout of PA
    contracts[0].element(class: 'drawer-toggle').click
    contracts[0].element(class: 'fa-envelope').click

    TED.impersonate
    TED.go_to_payment_method_tab
    TED.add_payment
    TED.fill_out_form
    TED.select_dropdowns
    TED.sign_out

    goto_sign_page_via_url_in_email
    @browser.text_field(:placeholder, 'Signature').set @org_name; sleep 0.5
    @browser.button(text: 'I Accept').click

    sleep 3
    TED.fill_out_form
    TED.select_dropdowns
    sleep 3
    TED.go_to_payment_method_tab
    TED.add_payment
    TED.fill_out_form
    TED.select_dropdowns

    # check email by subject and delete it afterward
    signed_confirm = "#{@org_name} has signed Terms of Service and authorized credit card"
    signed_receipt = 'Team Edition Signed Contract Receipt'
    @gmail.mail_box = 'Inbox'
    [signed_confirm, signed_receipt].each do |subject|
      check_email(subject)
    end

    @gmail.mail_box = 'TED_Welcome'
    check_email
  end
end
