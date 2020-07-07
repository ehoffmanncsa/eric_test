# frozen_string_literal: true

require_relative '../test_helper'

# SALES-1653 TED Regression
# UI Test: Prepop org with a client has a Club Season record with the Club Name

#   Create new NCSA athlete via api
#   Login as new athlete, set password and add Club Season record with the Club Name
#   CClub Season record with the Club Name will match the Ted org name.
#   Create a new org in TED with primary contact
#   Make sure when login as admin(or coach but not testing that) the above athete
#   shows up on Roster -  Athletes page(pre-populated)

class CreateNewOrgWithPrepopOrgName < Common
  def setup
    super
    skip
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
    @athlete_zip = post_body[:recruit][:zip]
    first_name = post_body[:recruit][:athlete_first_name]
    last_name = post_body[:recruit][:athlete_last_name]
    @sport = post_body[:recruit][:sport_id]
    @athlete_name = "#{first_name} #{last_name}"

    UIActions.user_login(@athlete_email)
    MSSetup.set_password
  end

  def add_coach_reference
    C3PO.goto_athletics
    fill_out_club_team
  end

  def fill_out_club_team
    # open form
    coach_section = @browser.element(class: 'club_seasons_section')
    coach_section.element(class: 'add_icon').click
    form = @browser.element(id: 'club_season_edit')

    # fill out text fields, matching on coach email only
    form.element(name: 'name').send_keys @org_name
    form.element(name: 'team_level').send_keys 'Varsity'
    form.element(name: 'notes').send_keys MakeRandom.lorem

    # select year
    years_dropdown = form.select_list(name: 'year')
    years = years_dropdown.elements(tag_name: 'option')
    years.to_a.sample.click

    # submit form
    form.element(class: 'submit').click; sleep 0.5
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
          zip_code: @athlete_zip
        },
        relationships: {
          partner: { data: { type: 'partners' } },
          sport: { data: [{ type: 'sports', id: @sport }] }
        },
        type: 'organizations'
      }
    }.to_json
  end

  def name_cap(name)
    temp = name.split(' ')
    temp.each(&:capitalize!)
    name = temp.join(' ')
  end

  def test_prepop_org_name
    create_athlete
    add_coach_reference
    sleep 5 # system needs a little time before creating org

    TEDOrgApi.setup
    pp "[INFO] Creating Org - #{@org_name}"
    new_org = TEDOrgApi.create_org(org_body)
    TED.impersonate_org(new_org['id'])
    TED.go_to_athlete_tab

    failure = []
    begin
      five_minutes = 300 # seconds
      Timeout.timeout(five_minutes) do
        loop do
          html = @browser.html
          break if html.include? @athlete_name

          @browser.refresh
        end
      end
    rescue StandardError => e
      failure << 'Athlete not pre-populated after 2 minutes wait'
    end
    assert_empty failure

    TEDOrgApi.delete_org(new_org['id'])
  end
end
