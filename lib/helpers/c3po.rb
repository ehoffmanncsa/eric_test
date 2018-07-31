# encoding: utf-8
require_relative '../../test/test_helper'

# This helper is to help in performing C3PO related actions
module C3PO
  def self.setup(ui_object)
    @browser = ui_object
    UIActions.setup(@browser)
  end

  def self.teardown
    @browser.close
  end

  def self.upload_video(file = nil)
    file ||= 'sample.mp4'
    path = File.absolute_path("test/videos/#{file}")

    # open upload section
    @browser.element(:class, 'js-upload-options').element(:class, 'fa-plus').click
    form = @browser.form(:id, 'profile-video-upload')

    # fill out the upload form
    form.select_list(:id, 'uploaded_video_as_is').select('Yes')
    form.text_field(:id, 'uploaded_video_position').set SecureRandom.hex(4)
    form.text_field(:id, 'uploaded_video_jersey_number').set SecureRandom.hex(4)
    form.text_field(:id, 'uploaded_video_jersey_color').set SecureRandom.hex(4)

    # send in file path and upload
    form.file_field(:id, 'profile-video-upload-file-input').set path
    form.button(:name, 'commit').click
    Watir::Wait.until { @browser.div(:class, 'js-video-files-container').visible? }
  end

  def self.upload_youtube(admin = true)
    url = 'https://www.youtube.com/watch?v=YtfZeoFU0J0'
    @browser.element(:class, 'js-upload-options').element(:class, 'fa-youtube').click
    form = @browser.form(:id, 'profile-youtube-video-upload')

    # fill out the upload form
    form.text_field(:id, 'external_video_title').set SecureRandom.hex(4)
    form.text_field(:id, 'external_video_embed_code').set url

    # click this checkbox if available (when login as admin)
    begin
      form.checkbox(:id, 'verified').click if admin
    rescue; end

    form.button(:name, 'commit').click
    Watir::Wait.while { form.element(:class, 'action-spinner').visible? }
  end

  def self.upload_hudl(admin = true)
    url = 'http://www.hudl.com/video/3/8650926/58f3b097bee0b52f8c96bfd5'
    @browser.element(:class, 'js-upload-options').element(:class, 'fa-custom-hudl').click
    form = @browser.form(:id, 'hudl-embed-video-upload')

    # fill out the upload form
    form.text_field(:id, 'external_video_title').set SecureRandom.hex(4)
    form.text_field(:id, 'external_video_embed_code').set url

    # click this checkbox if available (when login as admin)
    begin
      form.checkbox(:id, 'verified').click if admin
    rescue; end

    form.button(:name, 'commit').click
    Watir::Wait.while { form.element(:class, 'action-spinner').visible? }
  end

  def self.send_to_video_team
    section = @browser.div(:class, 'js-video-files-container')
    section.element(:class, 'button--primary').click
    @browser.element(:class, 'button--primary').click
  end

  def self.impersonate(recruit_email)
    UIActions.fasttrack_login
    @browser.goto 'https://qa.ncsasports.org/fasttrack/client/Search.do'

    # search for client via email address
    begin
      retries ||= 0
      @browser.text_field(:name, 'emailAddress').set recruit_email
      @browser.button(:name, 'button').click

      Watir::Wait.until { @browser.table(:class, 'breakdowndatatable').exists? }
      @table = @browser.table(:class, 'breakdowndatatable')
    rescue
      @browser.text_field(:name, 'emailAddress').clear
      retry if (retries += 1) < 3
    end

    column = @table.elements(:tag_name, 'td')[1]
    column.element(:tag_name, 'button').click; sleep 1

    @browser.window(:index, 1).use
  end

  def self.open_tracking_note(client_id)
    @browser.goto "https://qa.ncsasports.org/clientrms/profile/recruiting_profile/#{client_id}/admin"
    side_bar = @browser.elements(:class, 'side-bar')[1]
    nav_bar = side_bar.element(:class, 'm-nav-vert')
    nav_bar.elements(:tag_name, 'li')[1].click
  end

  def self.goto_video
    @browser.element(:id, 'profile_summary_button').click
    @browser.element(:class, 'subheader').element(:id, 'edit_video_link').click
  end

  def self.goto_publish
    goto_video
    @browser.element(:class, 'pub').click
  end

  def self.activate_first_row_of_new_video
    new_video_btn = @browser.elements(:class, 'm-button-gray').first
    new_video_btn.click
  end

  def self.publish_video(file = nil)
    file ||= 'sample.mp4'
    path = File.absolute_path("test/videos/#{file}")

    row = @browser.element(:id, 'cvt-videos').elements(:tag_name, 'tr')[0]
    video_id = row.attribute('id').split('-').last

    # Execute javascript to inject associate id for video
    assoc_id = @browser.element(:id, 'assoc_id')
    inject_id = "return arguments[0].value = #{video_id}"
    @browser.execute_script(inject_id, assoc_id)

    @browser.form(:id, 'direct-upload').file_field(:id, 'file').send_keys path
    @browser.element(:id, 'email_subject').send_keys SecureRandom.hex(4); sleep 2
    @browser.button(:value, 'Send Email').click
  end

  def self.wait_for_video_thumbnail
    # goto Preview Profile
    @browser.element(:class, 'profile-button-link').click; sleep 2
    @browser.window(:index, 2).use
    Watir::Wait.until { @browser.title.include? 'NCSA Client Recruiting' }

    section = @browser.element(:id, 'video-section')
    div = section.div(:class, 'video-link')
    # keep refresh browser for 180s or until thumbnail shows up
    Timeout::timeout(180) {
      loop do
        begin
          div.element(:class, 'thumbnail').visible?
          @thumbnail = div.element(:class, 'thumbnail')
        rescue => e
          @browser.refresh; retry
        end

        break if @thumbnail
      end
    }

    @thumbnail
  end

  def self.goto_athletics
    # go to Athletics
    subheader = @browser.element(:class, 'subheader')
    subheader.element(:id, 'edit_athletic_link').click
  end

 

  def self.add_hs_team
    hs_section = @browser.element(:class, 'high_school_seasons')
    hs_section.element(:class, 'add_icon').click

    form = @browser.element(:id, 'high_school_season_form_container')

    # select random year
    years_dropdown = form.select_list(:name, 'year')
    years = years_dropdown.elements(:tag_name, 'option').to_a
    years.shift; years.sample.click

    # select random team
    teams_dropdown = form.select_list(:name, 'level')
    teams = teams_dropdown.elements(:tag_name, 'option').to_a
    teams.shift; teams.sample.click

    # click radio button and give jersey number
    # sometimes these 2 dont show up so just ignore them
    begin
      Watir::Wait.until { form.element(:name, 'season_team_info[starter]').visible? }
      form.element(:name, 'season_team_info[starter]').click
      Watir::Wait.until { form.element(:name, 'season_team_info[jersey_number]').visible? }
      form.element(:name, 'season_team_info[jersey_number]').set MakeRandom.number(2)
    rescue; end

    # add schedule file
    path = File.absolute_path('test/c3po/cat.png')
    upload_form = form.element(:id, 'schedule_upload_form')
    upload_form.file_field(:id, 'file').set path

    # check boxes left table
    tables = form.elements(:class, 'athletic_awards')
    tables.each do |table|
      rows = table.elements(:tag_name, 'tr').to_a
      rows.shift
      for i in 0 .. rows.length - 2
        rows[i].elements(:class, 'cb_award').to_a.sample.click
      end

      rows.last.text_field(:class, 'text_award').set MakeRandom.name
    end

    #submit
    form.element(:class, 'submit').click; sleep 1
  end

  def self.add_club_team
    url = 'https://chicago.suntimes.com/'
    path = File.absolute_path('test/c3po/cat.png')

    # open club form
    club_section = @browser.element(:class, 'club_seasons')
    club_section.element(:class, 'add_icon').click

    # fill out form
    club_form = @browser.element(:id, 'club_season_form_container')
    ['name', 'team_level'].each do |name|
      club_form.text_field(:name, name).set MakeRandom.name
    end

    # some sport doesnt require jersey number so just ignore
    begin
      Watir::Wait.until { club_form.text_field(:name, 'jersey_number').visible? }
      club_form.text_field(:name, 'jersey_number').set MakeRandom.number(2)
    rescue; end

    club_form.text_field(:name, 'external_schedule_url').set url
    club_form.file_field(:id, 'file').set path
    club_form.textarea(:name, 'notes').set MakeRandom.name

    # select random year
    dropdown = club_form.select_list(:name, 'year')
    years = dropdown.options.to_a; years.shift
    dropdown.select(years.sample.text)

    # submit form
    club_form.element(:class, 'submit').click; sleep 1
  end

  def self.open_athlete_history_popup
    # go to Preview Profile
    @browser.element(:class, 'button--primary').click; sleep 1
    history_section = @browser.element(:id, 'athletic-section')
    history_section.scroll.to; sleep 1
    stat = history_section.elements(:tag_name, 'li').to_a.sample
    Watir::Wait.until { stat.element(:class, 'mg-right-1').visible? }
    stat.element(:class, 'mg-right-1').click
  end

  def self.get_popup_stats_headers
    self.open_athlete_history_popup
    headers = []
    popup = @browser.element(:class, 'mfp-content')
    popup.elements(:tag_name, 'h6').each { |e| headers << e.text.downcase }

    headers.join(',')
  end

  def self.goto_academics
    # go to Athletics
    subheader = @browser.element(:class, 'subheader')
    subheader.element(:id, 'edit_academics_link').click
  end

  def self.goto_my_information
    # go to My Information page
    subheader = @browser.element(:class, 'subheader')
    subheader.element(:id, 'edit_my_information_link').click
  end
  
end
