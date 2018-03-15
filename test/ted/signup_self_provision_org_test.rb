# encoding: utf-8
require_relative '../test_helper'

# TS-376: TED Regression
# UI Test: Organization Can Sign Up as Free Unverified User on TED Sign In Page (Club)

=begin
  Sign up for new org from login page
  Using org type Club, since it is hard to tell which HS
   in which zipcode has yet to have an org associates with
  After org is created, user is logged in as coach
  Verify his status is unverified and he cannot verify himself
  Login as PA verify this org in in Unverified section and
  is labled "Self Provisioned"
  PA impersonate org and verify coach, make sure coach status is verified
  After verify coach, make sure org is in Free Signed section now
  Also make sure Intro email is received and delete it
  Delete org after all
=end

class SignupSelfProvisionOrgTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection

    @org_name = MakeRandom.name

    creds = YAML.load_file('config/.creds.yml')
    @admin_username = creds['ted_admin']['username']
    @admin_password = creds['ted_admin']['password']
  end

  def teardown
    @browser.close
  end

  def modal
    @browser.div(:class, 'modal-content')
  end

  def open_club_form
    @browser.goto 'https://team-staging.ncsasports.org/sign_in'
    @browser.elements(:text, 'Sign Up')[1].click
    assert modal, 'Add Organization modal not found'

    # select club
    list = modal.select_list(:class, 'form-control')
    list.select 'Club'; sleep 0.5

    # Make sure name is unique
    # Retry if name found
    loop do
      modal.text_field(:class, 'resizable-input').set MakeRandom.name; sleep 0.5
      break if (modal.div(:class, 'alert').present? && 
        modal.div(:class, 'alert').text == 'No Clubs Found with that name.')
    end

    modal.button(:text, 'Create a New Club').click
  end

  def fill_out_form
    # fill out club info
    inputs = modal.elements(:tag_name, 'input').to_a
    inputs[0].send_keys @org_name
    inputs[3].send_keys 'IL'
    inputs[4].send_keys MakeRandom.number(5)
    inputs[5].send_keys MakeRandom.name
    inputs[6].send_keys MakeRandom.name
    inputs[7].send_keys MakeRandom.email
    inputs[8].send_keys MakeRandom.number(10)

    # select info from dropdowns in modal
    lists = modal.select_lists(:class, 'form-control')
    lists[0].select 'US'
    lists[2].options.to_a.sample.select
    modal.button(:text, 'Add').click; sleep 3
  end

  def give_password
    modal = @browser.divs(:class, 'modal-content')[1]
    modal.elements(:tag_name, 'input').each do |i|
      i.send_keys 'ncsa'
    end

    modal.button(:text, 'Change Password').click; sleep 1
  end

  def sign_TOS
    modal.text_field(:placeholder, 'Signature').set @org_name
    modal.button(:text, 'I Accept').click; sleep 3
  end

  def verify_coach_unverified
    TED.go_to_staff_tab
    assert @browser.button(:text, 'Unverified').enabled?, 'Button Unverified not found'
  end

  def verify_coach_cannot_self_verify
    @browser.button(:text, 'Unverified').click
    assert modal, 'No Alert modal found'

    text = 'You do not have permission to verify coaches.'
    assert_includes modal.text, text, 'Wrong alert message'

    # close modal and sign out
    modal.element(:class, 'fa-times').click
    TED.sign_out
  end

  def verify_org_unverfied
    UIActions.ted_login(@admin_username, @admin_password)
    Watir::Wait.while { @browser.element(:class, 'alert').present? }

    list = @browser.select_list(:class, 'form-control')
    list.select 'Unverified'

    Watir::Wait.while { @browser.element(:class, 'alert').present? }
    assert_includes @browser.html, @org_name, 'Org not found in Unverified'
  end

  def verify_org_self_provisoned
    org = @browser.element(:text, @org_name).parent.parent
    assert_includes org.html, 'Self Provisioned', 'Self Provisioned label not found'
  end

  def admin_verify_coach
    org = @browser.element(:text, @org_name).parent
    org.click

    @org_id = @browser.url.split('/').last.to_s

    @browser.link(:text, 'Enter Org as Coach').click
    TED.go_to_staff_tab
    @browser.button(:text, 'Unverified').click
    assert modal, 'Coach Verification modal not found'

    modal.button(:text, 'Verify').click; sleep 1
    assert (@browser.text.include? 'Verified'), 'Status Verified not found'

    TED.sign_out
  end

  def verify_org_free_signed
    UIActions.ted_login(@admin_username, @admin_password)
    Watir::Wait.while { @browser.element(:class, 'alert').present? }

    list = @browser.select_list(:class, 'form-control')
    list.select 'Accepted' # this is value for Free Signed option

    Watir::Wait.while { @browser.element(:class, 'alert').present? }
    assert_includes @browser.html, @org_name, 'Org not found in Free Signed'
  end

  def check_email(subject)
    @gmail.mail_box = 'Inbox'
    @gmail.subject = subject
    emails = @gmail.get_unread_emails
    refute_empty emails, 'No Intro email received'

    @gmail.delete(emails)
  end

  def delete_org
    TEDOrgApi.setup
    TEDOrgApi.delete_org(@org_id)
  end

  def test_signup_self_provision_org
    open_club_form
    fill_out_form
    give_password
    sign_TOS
    verify_coach_unverified
    verify_coach_cannot_self_verify

    verify_org_unverfied
    verify_org_self_provisoned

    admin_verify_coach
    verify_org_free_signed
    check_email('Introduction to Team Edition')
    delete_org
  end
end
