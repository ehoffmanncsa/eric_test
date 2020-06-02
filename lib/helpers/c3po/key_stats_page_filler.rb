# require 'pry'
module C3PO
  class KeyStatsPageFiller < C3PO::KeyStatsPage

    def initial
      super
    end

    def select_primary_position
      dropdown = @browser.element(id: 'primary_position')
      options = dropdown.elements(tag_name: 'option').to_a
      options.shift
      if options.count == 0
        return false
      else
        random_primary_position = options.sample
        @selected_primary_position = random_primary_position.text
        random_primary_position.click
        sleep 1
      end
    end

    def selected_primary_position
      @selected_primary_position
    end

    def select_height_feet
      dropdown = @browser.element(id: 'height_feet')
      options = dropdown.elements(tag_name: 'option').to_a
      options.shift
      if options.count == 0
        return false
      else
        random_height_feet = options.sample
        @selected_height_feet = random_height_feet.text
        random_height_feet.click
        sleep 1
      end
    end

    def selected_height_feet
      @selected_height_feet
    end

    def select_height_inches
      dropdown = @browser.element(id: 'height_inches')
      options = dropdown.elements(tag_name: 'option').to_a
      options.shift
      if options.count == 0
        return false
      else
        random_height_inches = options.sample
        @selected_height_inches = random_height_inches.text
        random_height_inches.click
        sleep 1
      end
    end

    def selected_height_inches
      @selected_height_inches
    end

    def select_weight
      dropdown = @browser.element(id: 'weight')
      options = dropdown.elements(tag_name: 'option').to_a
      options.shift
      if options.count == 0
        return false
      else
        random_weight = options.sample
        @selected_weight = random_weight.text
        random_weight.click
        sleep 1
      end
    end

    def selected_weight
      @selected_weight
    end

    def select_hand
      dropdown = @browser.element(id: 'handed')
      options = dropdown.elements(tag_name: 'option').to_a
      options.shift; options.sample.click
    end

    def select_timing_fourty_yard_dash
      dropdown = @browser.element(id: '40_Yard_Dash_measurable_option')
      options = dropdown.elements(tag_name: 'option').to_a
      options.shift; options.sample.click
    end

    def select_timing_five_ten_five
      dropdown = @browser.element(id: '5-10-5_Shuttle_measurable_option')
      options = dropdown.elements(tag_name: 'option').to_a
      options.shift; options.sample.click
    end

    def fill_out_textfields
      key_stats_textfields.each do |element_id, value|
        element = @browser.text_field(id: element_id.to_s)
        element.scroll.to :center
        element.set value
      end
    end

    def submit
      @browser.button(value: 'Save').click
      sleep 5
    end
  end
end
