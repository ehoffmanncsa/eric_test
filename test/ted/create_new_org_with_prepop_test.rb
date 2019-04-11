# encoding: utf-8
require_relative '../test_helper'

# TS-351: TED Regression
# UI Test: Adding an Organization With a $0 Contract

=begin
  Create new NCSA athlete via api
  Login as new athlete, set password and add coach reference
  Create a new org in TED with primary contact is the above coach
  Make sure when login as coach (or impersonate?) the above athete
    shows up on coach dashboard (pre-populated)
=end

class CreateNewOrgWithPrepop < Common
  def setup
    super
    C3PO.setup(@browser)
    MSSetup.setup(@browser)
    TED.setup(@browser)

    @org_name = MakeRandom.company_name
    @coach_firstname = MakeRandom.first_name
    @coach_lastname = MakeRandom.last_name
    @coach_name = "#{@coach_firstname} #{@coach_lastname}"
    @coach_email = MakeRandom.email
    @phone_number = MakeRandom.phone_number
  end

  def teardown
    super
  end

  def create_athlete
    # add a new freshman recruit, get back his email address and username
    _post, post_body = RecruitAPI.new.ppost
    @athlete_email = post_body[:recruit][:athlete_email]
    first_name = post_body[:recruit][:athlete_first_name]
    last_name = post_body[:recruit][:athlete_last_name]
    @athlete_name = "#{first_name} #{last_name}"

    UIActions.user_login(@athlete_email)
    MSSetup.set_password(@athlete_email)
  end

  def add_coach_reference
    UIActions.goto_edit_profile

    C3PO.goto_athletics
    fill_out_form
  end

  def fill_out_form
    # open form
    coach_section = @browser.element(:class, 'coach_references_section')
    coach_section.element(:class, 'add_icon').click
    form = @browser.element(:id, 'coach_reference_edit')

    # fill out text fields
    form.element(:name, 'name').send_keys @coach_name
    form.element(:name, 'phone').send_keys @phone_number
    form.element(:name, 'email').send_keys @coach_email

    # select club coach type
    dropdown = form.select_list(:name, 'coach_type')
    dropdown.select 'Club Coach'

    # select radio button yes
    form.radio(:value, 'true').set

    # submit form
    form.element(:class, 'submit').click; sleep 0.5
  end

  def org_body
    sport_id = Default.static_info['sport_ids'].sample.to_s
    body = {
      data: {
        attributes: {
          address: '1234 El Taco',
          city: 'Chicago',
          email: @coach_email,
          first_name: @coach_firstname,
          last_name: @coach_lastname,
          name: @org_name,
          phone: @phone_number,
          state: 'IL',
          type: 'Organization',
          website: '',
          zip_code: MakeRandom.number(5)
        },
        relationships: {
          partner: { data: { type: 'partners' } },
          sport: { data: [{ type: 'sports', id: sport_id }] }
        },
        type: 'organizations'
      }
    }.to_json
  end

  def name_cap(name)
    temp = name.split(' ')
    temp.each { |word| word.capitalize! }
    name = temp.join(' ')
  end

  def test_create_org_with_existing_athlete
    create_athlete
    add_coach_reference

    TEDOrgApi.setup
    pp "[INFO] Creating Org - #{@org_name}"
    new_org = TEDOrgApi.create_org(org_body)
    TED.impersonate_org(new_org['id'])

    failure = []
    begin
      five_minutes = 300 # seconds
      Timeout::timeout(five_minutes) {
        loop do
          html = @browser.html
          break if html.include? name_cap(@athlete_name)
          @browser.refresh
        end
      }
    rescue => e
      failure << "Athlete not pre-populated after 2 minutes wait"
    end
    assert_empty failure

    TEDOrgApi.delete_org(new_org['id'])
  end
end
