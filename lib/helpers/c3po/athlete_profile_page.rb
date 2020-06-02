module C3PO
  # To locate elements on this page, should help with data verification
  class AthleteProfilePage
    def initialize(browser)
      @browser = browser
    end

    def athlete_fullname
      top_section.element(class: 'fullname').text
    end

    def athlete_grad_year
      top_section.div(class: 'stats').text.split(' ')[0]
    end

    def athlete_top_city
      top_section.span(class: 'city').text.split(',')[0]
    end

    def athlete_top_email
      top_section.element(class: 'fa-envelope').parent.text.strip
    end

    def athlete_top_phone
      top_section.element(class: 'fa-phone').parent.text.strip!
    end

    def athlete_bottom_email
      athlete_contact.element(visible_text: /recruitinginfo.org/).text
    end

    def athlete_bottom_phone
      athlete_contact.div(class: %w[phone primary]).element(tag_name: 'a').text
    end

    def athlete_secondary_phone
      athlete_contact.div(class: %w[phone secondary]).element(tag_name: 'a').text
    end

    def parent1_fullname
      # raw string comes like this "nam name (father)" - hence split and strip
      parent1_contact.element(tag_name: 'h5').text.split("(")[0].strip!
    end

    def parent1_email
      parent1_contact.element(visible_text: /@/).text
    end

    def parent1_phone
      parent1_contact.div(class: %w[phone primary]).element(tag_name: 'a').text
    end

    def parent1_secondary_phone
      parent1_contact.div(class: %w[phone secondary]).element(tag_name: 'a').text
    end

    def parent2_fullname
      # raw string comes like this "nam name (mother)" - hence split and strip
      parent2_contact.element(tag_name: 'h5').text.split("(")[0].strip!
    end

    def parent2_email
      parent2_contact.element(visible_text: /@/).text
    end

    def parent2_phone
      parent2_contact.div(class: %w[phone primary]).element(tag_name: 'a').text
    end

    def parent2_secondary_phone
      parent2_contact.div(class: %w[phone secondary]).element(tag_name: 'a').text
    end

    def athlete_address
      @browser.div(class: 'street-address').text
    end

    def athlete_bottom_city
      @browser.div(class: 'city').text.split(',')[0]
    end

    def athlete_zipcode
      @browser.div(class: 'city').text.split(' ').last
    end

    def personal_statement
      personal_statement = @browser.elements(class: %w[info-category personal-statement]).first.text
      personal_statement.gsub("PERSONAL STATEMENT\n", '')
    end

    def athlete_major
      study_field = academic_section.element(text: 'Preferred Field of Study').parent
      study_field.text.gsub("Preferred Field of Study\n", '')
    end

    def gpa_section
      @browser.elements(class: %w[score half mg-btm-1])[0].text
    end

    def act_section
      @browser.elements(class: %w[score half mg-btm-1])[1].text
    end

    def sat_section
      @browser.elements(class: %w[score half mg-btm-1])[2].text
    end

    def high_school
      @browser.elements(class: %w[half mg-btm-1])[3].text
    end

    def honors_section
      @browser.elements(class: %w[half accomplishments])[0].text
    end

    def academic_awards_section
      @browser.elements(class: %w[half awards])[0].text
    end
    def header_info_position
      top_section.div(class: 'stats').text.split(' ')[1]
    end

    def header_info_stats
      @browser.element(class: 'key-stats')
    end

    def keystats_40_yard_dash_time
      key_stats_section.div(class: 'stat-val').text.split(' ')[0]
    end

    def keystats_40_yard_dash_verified_by
      key_stats_section.div(class: 'event').text.split(' ')[2]
    end

    def keystats_40_yard_dash_verified_date
      key_stats_section.div(class: 'date').text.split(' ')[2]
    end

    def keystats_shuttle_time
      shuttle_time  = @browser.elements(class: 'stat-val')
      shuttle_time[1].text.split(' ')[0]
    end

    def keystats_shuttle_time_verified_by
      shuttle_time_verified_by = @browser.elements(class: 'event')
      shuttle_time_verified_by[1].text.split(' ')[2]
    end

    def keystats_shuttle_time_verified_date
      shuttle_time_verified_date = @browser.elements(class: 'date')
      shuttle_time_verified_date[1].text.split(' ')[2]
    end

    def keystats_bench_press_weight
      bench_press_weight  = @browser.elements(class: 'stat-val')
      bench_press_weight[2].text.split(' ')[0]
    end

    def keystats_bench_press_verified_by
      bench_press_verified_by = @browser.elements(class: 'event')
      bench_press_verified_by[2].text.split(' ')[2]
    end

    def keystats_bench_press_verified_date
      bench_press_verified_date = @browser.elements(class: 'date')
      bench_press_verified_date[2].text.split(' ')[2]
    end

    def keystats_squat_weight
      squat_weight  = @browser.elements(class: 'stat-val')
      squat_weight[3].text.split(' ')[0]
    end

    def keystats_squat_verified_by
      squat_verified_by = @browser.elements(class: 'event')
      squat_verified_by[3].text.split(' ')[2]
    end

    def keystats_squat_verified_date
      squat_verified_date = @browser.elements(class: 'date')
      squat_verified_date[3].text.split(' ')[2]
    end

    def keystats_vertical
      vertical  = @browser.elements(class: 'stat-val')
      vertical[4].text.split(' ')[0]
    end

    def keystats_vertical_verified_by
      vertical_verified_by = @browser.elements(class: 'event')
      vertical_verified_by[4].text.split(' ')[2]
    end

    def keystats_vertical_verified_date
      vertical_verified_date = @browser.elements(class: 'date')
      vertical_verified_date[4].text.split(' ')[2]
    end

    def keystats_three_cone
      three_cone  = @browser.elements(class: 'stat-val')
      three_cone[5].text.split(' ')[0]
    end

    def keystats_three_cone_verified_by
      three_cone_verified_by = @browser.elements(class: 'event')
      three_cone_verified_by[5].text.split(' ')[2]
    end

    def keystats_three_cone_verified_date
      three_cone_verified_date = @browser.elements(class: 'date')
      three_cone_verified_date[5].text.split(' ')[2]
    end

    def keystats_broad_jump
      broad_jump  = @browser.elements(class: 'stat-val')
      broad_jump[6].text.split(' ')[0]
    end

    def keystats_broad_jump_verified_by
      broad_jump_verified_by = @browser.elements(class: 'event')
      broad_jump_verified_by[6].text.split(' ')[2]
    end

    def keystats_broad_jump_verified_date
      broad_jump_verified_date = @browser.elements(class: 'date')
      broad_jump_verified_date[6].text.split(' ')[2]
    end

    private

    def top_section
      @browser.section(class: %w[top snapshot])
    end

    def academic_section
      @browser.div(id: 'academic-section')
    end

    def about_section
      @browser.div(id: 'about-section')
    end

    def video_section
      @browser.section(id: 'video-section')
    end

    def contact_section
      @browser.section(id: 'contact-section')
    end

    def key_stats_section
      @browser.div(class: %w[key-stats-hist mg-top-1])
    end

    def athlete_contact
      contact_section.divs(class: %w[half mg-btm-1])[0]
    end

    def parent1_contact
      contact_section.divs(class: %w[half mg-btm-1])[2]
    end

    def parent2_contact
      contact_section.divs(class: %w[half mg-btm-1])[1]
    end
  end
end
