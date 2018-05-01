# encoding: utf-8
require_relative '../test_helper'

# TS-352: TED Regression
# UI Test: Allow Org Coach and NCSA Admin to Add Payment Method

=begin
  PA Otto Mation reates a new org for each test run
  Send a free invoice (email) to org and get coach login password there
  Note: org is now in Free Sent
  Get coach admin info then login and add payment
  Login as PA, imperson org and add payment
  Delete org afterward
=end

class AddPaymentMethodTest < Common
  def setup
    super
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection

    creds = YAML.load_file('config/.creds.yml')
    @admin_username = creds['ted_admin']['username']
    @admin_password = creds['ted_admin']['password']

    @new_org = create_org
    @org_id = @new_org['id']
  end

  def teardown
    TEDOrgApi.org_id = @org_id
    TEDOrgApi.delete_org
    super
  end

  def create_org
    TEDOrgApi.setup
    @admin_api = TEDOrgApi.admin_api
    TEDOrgApi.create_org
  end

  def send_free_invite_email
    TEDContractApi.admin_api = @admin_api
    TEDContractApi.send_free_invoice(@org_id)
  end

  def get_coach_password
    # use keyword 'password' to look for password in gmail
    @gmail.mail_box = 'Inbox'
    @gmail.subject = 'Get Started with Team Edition'
    emails = @gmail.get_unread_emails
    msg = @gmail.parse_body(emails.last, 'PASSWORD')
    password = msg[1].split(':').last.split()[0].split('<')[0]
    @gmail.delete(emails)

    password
  end

  def give_password
    modal = @browser.divs(:class, 'modal-content')[1]
    modal.elements(:tag_name, 'input').each do |i|
      i.send_keys 'ncsa'
    end

    modal.button(:text, 'Change Password').click; sleep 1
  end

  def sign_TOS
    TED.modal.text_field(:placeholder, 'Signature').set @new_org['attributes']['name']
    TED.modal.button(:text, 'I Accept').click; sleep 3
  end

  def add_payment
    # open add payment method modal
    @browser.button(:text, 'Add Payment Method').click

    fill_out_form
    select_dropdowns
    TED.modal.button(:text, 'Submit').click; sleep 3
  end

  def fill_out_form
    first_name = MakeRandom.name
    last_name = MakeRandom.name

    inputs = TED.modal.elements(:tag_name, 'input')
    inputs[0].send_keys first_name
    inputs[1].send_keys last_name
    inputs[2].send_keys '4242424242424242'
    inputs[3].send_keys '123'
    inputs[4].send_keys MakeRandom.number(5)
    inputs[5].send_keys MakeRandom.email

    # also return name for assertion
    @full_name = "#{first_name} #{last_name}"
  end

  def select_dropdowns
    lists = TED.modal.select_lists(:class, 'form-control')
    lists.each do |list|
      options = list.options.to_a
      options.shift
      list.select options.sample.text
    end
  end

  def test_coach_add_payment_method
    send_free_invite_email
    coach_password = get_coach_password
    coach_username = @new_org['attributes']['email']

    UIActions.ted_login(coach_username, coach_password)
    give_password
    sign_TOS

    TED.go_to_payment_method_tab
    add_payment

    TED.go_to_payment_method_tab
    assert_includes @browser.html, @full_name, 'New payment method not found'
  end

  def test_PA_add_payment_method
    TED.impersonate_org(@org_id)
    TED.go_to_payment_method_tab
    add_payment

    TED.go_to_payment_method_tab
    assert_includes @browser.html, @full_name, 'New payment method not found'
  end
end
