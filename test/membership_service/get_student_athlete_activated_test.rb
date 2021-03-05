# encoding: utf-8
require_relative '../test_helper'

# TS-434: MS Regression
# UI Test: How student-athlete becomes Activation
class GetStundentAthleteActivatedTest < Common
  def setup
    super

    MSSetup.setup(@browser)
    C3PO.setup(@browser)

    _post, post_body = RecruitAPI.new.ppost
    @recruit_email = post_body[:recruit][:athlete_email]
  end

  def teardown
    super
  end

  def get_activated
    UIActions.user_login(@recruit_email)
    MSSetup.set_password
    MSSetup.goto_offerings
  end

  def sign_out
    clientrms = Default.env_config['clientrms']
    url = clientrms['base_url'] + clientrms['dashboard']
    @browser.goto url

    C3PO.sign_out
  end

  def find_the_new_client
    UIActions.fasttrack_login

    header = @browser.div(id: 'header')
    update = header.elements(tag_name: 'li').detect { |e| e.text == 'Update' }

    update.hover; sleep 1
    header.link(id: 'updateClient').click; sleep 1

    @browser.text_field(name: 'emailAddress').set @recruit_email
    @browser.checkbox(name: 'freePartnerMembership').set

    @browser.button(text: 'Search').click; sleep 1
  end

  def check_for_activation
    wrapper = @browser.element(class: 'dataTables_wrapper')
    table = wrapper.table(class: 'breakdowndatatable')

    #         table[row][collumn]
    program = table[1][8].text
    assert_equal 'Activation', program, 'Program is not Activation'
  end

  def test_get_student_athlete_activated
    get_activated
    #sign_out
    find_the_new_client
    check_for_activation
  end
end
