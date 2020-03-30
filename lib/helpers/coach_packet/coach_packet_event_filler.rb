# require 'pry'
module CP
  class CoachPacketFiller < CP::CoachPacketEvent

    def initial
      super
    end

    def fill_out_cp_textfields
        event_textfields.each do |element_id, value|
        element = @browser.text_field(name: element_id.to_s)
        element.set value
      end
    end

    def fill_out_cp_datefields
      @browser.date_field(name: 'start_date').set @start_date
      @browser.date_field(name: 'end_date').set @end_date
    end

    def fill_out_cp_timefields
      @browser.time_field(name: 'start_time').set @start_time
      @browser.time_field(name: 'end_time').set @end_time
    end

    def fill_out_cp_radiofields
      @browser.radio(value: 'Activated').set
      @browser.radio(value: 'non-purchasable').set
      @browser.radio(value: 'true').set
    end

    def select_state
      dropdown = @browser.element(name: 'state')
      options = dropdown.elements(tag_name: 'option').to_a

      options.each do |option|
        option.click if option.value == 'IL'
      end
    end

    def select_sport
      dropdown = @browser.element(name: 'sports[]')
      options = dropdown.elements(tag_name: 'option').to_a

      options.each do |option|
        option.click if option.value == '17638'
      end
    end

    def select_event_operator
      dropdown = @browser.element(name: 'event_operator_id')
      options = dropdown.elements(tag_name: 'option').to_a

      options.each do |option|
        option.click if option.value == '9' #Zero Gravity
      end
      sleep 2
    end

    def venue_data
      @browser.text_field(name: 'address1').set @address
      @browser.text_field(name: 'address2').set @address
      @browser.text_field(name: 'city').set @city
      @browser.text_field(name: 'name').set 'testvenue1'
      @browser.text_field(name: 'zip').set @zip
    end

    def venue_data2
      @browser.text_field(name: 'address1').set @address
      @browser.text_field(name: 'address2').set @address
      @browser.text_field(name: 'city').set @city
      @browser.text_field(name: 'name').set 'testvenue2'
      @browser.text_field(name: 'zip').set @zip
    end


    def submit
      @browser.button(value: 'Create').click
    end
  end
end
