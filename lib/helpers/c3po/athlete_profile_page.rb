module C3PO
  # To locate elements on this page, should help with data verification
  class AthleteProfilePage
    def initialize(browser)
      @browser = browser
    end

    def athlete_fullname
      top_section.element(:class, 'fullname').text
    end

    def athlete_grad_year
      top_section.div(:class, 'stats').text.split(' ')[0]
    end

    def athlete_top_city
      top_section.span(:class, 'city').text.split(',')[0]
    end

    def athlete_top_email
      top_section.element(:class, 'fa-envelope').parent.text.strip
    end

    def athlete_top_phone
      top_section.element(:class, 'fa-phone').parent.text.strip!
    end

    def athlete_bottom_email
      athlete_contact.element(:visible_text, /recruitinginfo.org/).text
    end

    def athlete_bottom_phone
      athlete_contact.div(:class, %w[phone primary]).element(:tag_name, 'a').text
    end

    def athlete_secondary_phone
      athlete_contact.div(:class, %w[phone secondary]).element(:tag_name, 'a').text
    end

    def parent1_fullname
      # raw string comes like this "nam name (father)" - hence split and strip
      parent1_contact.element(:tag_name, 'h5').text.split("(")[0].strip!
    end

    def parent1_email
      parent1_contact.element(:visible_text, /@/).text
    end

    def parent1_phone
      parent1_contact.div(:class, %w[phone primary]).element(:tag_name, 'a').text
    end

    def parent1_secondary_phone
      parent1_contact.div(:class, %w[phone secondary]).element(:tag_name, 'a').text
    end

    def parent2_fullname
      # raw string comes like this "nam name (mother)" - hence split and strip
      parent2_contact.element(:tag_name, 'h5').text.split("(")[0].strip!
    end

    def parent2_email
      parent2_contact.element(:visible_text, /@/).text
    end

    def parent2_phone
      parent2_contact.div(:class, %w[phone primary]).element(:tag_name, 'a').text
    end

    def parent2_secondary_phone
      parent2_contact.div(:class, %w[phone secondary]).element(:tag_name, 'a').text
    end

    def athlete_address
      @browser.div(:class, 'street-address').text
    end

    def athlete_bottom_city
      @browser.div(:class, 'city').text.split(',')[0]
    end

    def athlete_zipcode
      @browser.div(:class, 'city').text.split(' ').last
    end

    def personal_statement
      @browser.elements(:class, %w[info-category personal-statement]).first.text
    end

    def athlete_major
      study_field = academic_section.element(:text, 'Preferred Field of Study').parent
      study_field.text.gsub("Preferred Field of Study\n", '')
    end

    private

    def top_section
      @browser.section(:class, %w[top snapshot])
    end

    def academic_section
      @browser.div(:id, 'academic-section')
    end

    def about_section
      @browser.div(:id, 'about-section')
    end

    def video_section
      @browser.section(:id, 'video-section')
    end

    def contact_section
      @browser.section(:id, 'contact-section')
    end

    def athlete_contact
      contact_section.divs(:class, %w[half mg-btm-1])[0]
    end

    def parent1_contact
      contact_section.divs(:class, %w[half mg-btm-1])[2]
    end

    def parent2_contact
      contact_section.divs(:class, %w[half mg-btm-1])[1]
    end
  end
end
