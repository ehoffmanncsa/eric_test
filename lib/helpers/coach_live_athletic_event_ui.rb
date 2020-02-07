require_relative '../../test/test_helper'
# encoding: utf-8
#
# commom UI actions for Coach Live
module AthleticEventUI

  def self.setup(ui_object)
    @browser = ui_object
    UIActions.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
  end

  def self.adjust_window
    # adjust browser size
    width = 411
    height = 731
    @browser.window.resize_to(width, height)
  end

  def self.request_login
    @browser.goto 'http://coachlive-staging.ncsasports.org/login'
    sleep 3

    email = @browser.text_field(name: 'email')
    email.set 'ncsa.automation+coachlive@gmail.com'

    submit_button = @browser.button(text: 'NEXT')
    submit_button.click
    sleep 3
  end

  def self.get_new_coachlive_email
    @gmail.mail_box = 'CoachLive'
    @gmail.get_unread_emails.last
  end

  def self.get_login_url
    @email = get_new_coachlive_email

    keyword = '/wf/click?'

    msg = @gmail.parse_body(@email, keyword).strip!
    msg = "http" + msg.split('http')[1]

    msg
  end

  def self.delete_email
    @email.delete!
  end

  def self.display_upcoming_events
    @browser.element("data-automation-id": 'ViewAllUpcoming').click
    sleep 1
  end

  def self.display_past_events
    @browser.element("data-automation-id": 'ViewAllPast').click
    sleep 1
  end

  def self.search_for_event
    search = @browser.element("data-automation-id": 'SearchBox')
    search.scroll.to
    @browser.text_field(type: 'text').set @event_name
    sleep 2
  end

  def self.open_event
    open_event = @browser.element(text: @event_name)
    open_event.click
    sleep 2
  end

  def self.athlete_jersey_number
    display_jersey_number = @browser.element("data-automation-id": 'JerseyNumber').text
  end

  def self.athlete_name
    #athlete name on the event page
    display_athlete_name = @browser.element("data-automation-id": 'AthleteName').text
  end

  def self.athlete_name_profile
    #athlete name on the athlete profile page
    display_athlete_name = @browser.element("data-automation-id": 'EventName').text
  end

  def self.grad_year_position
    #both elements are captured under same front end id GradYear
    display_grad_year_position = @browser.element("data-automation-id": 'GradYear').text
  end

  def self.height_weight
    #both elements are captured under same front end id GradYear
    display_height = @browser.element("data-automation-id": 'HeightAndWeight').text
  end

  def self.gpa
    #both elements are captured under same front end id GradYear
    display_gpa = @browser.element("data-automation-id": 'TestScore').text
  end

  def self.team_org_info
    #both elements are captured under same front end id TeamInfo
    display_team_info = @browser.element("data-automation-id": 'TeamInfo').text
  end

  def self.open_athlete_profile
    @browser.element("data-automation-id": 'AthleteName').click
  end

  def self.open_athlete_rms
    @browser.element("data-automation-id": 'EventLogo').click
  end

  def self.select_hamburger_menu
    @browser.element(data_icon: 'bars').click
    sleep 3
  end

  def self.select_tracked_athlete_page
    @browser.element(text: 'Athletes').click
    sleep 8
  end

  def self.select_events_page
    @browser.element(text: 'Events').click
    sleep 8
  end

  def self.signup_message
    @browser.element(role: 'alertdialog').text
  end

  def self.tag
   tag_arr = ['tag1','tag2','tag3','tag4','tag5','tag6']

   tag_arr.sample
  end

  def self.sports
   sports_arr = ['Softball', 'Men''s Basketball', 'Women''s Basketball', 'Men''s Ice Hockey',
     'Women''s Ice Hockey', 'Men''s Soccer', 'Women''s Soccer', 'Men''s Water Polo',
      'Women''s Water Polo', 'Baseball', 'Men''s Lacrosse','Women''s Lacrosse']

   sports_arr.sample
  end
end
