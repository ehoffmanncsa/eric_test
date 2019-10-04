# require 'pry'
module C3PO
  class AcademicsPageFiller < C3PO::AcademicsPage

    def initial
      super
    end

    def fill_out_textfields
      academics_textfields.each do |element_id, value|
        element = @browser.text_field(id: element_id.to_s)
        element.scroll.to :center
        element.set value
      end
    end

    def fill_out_textareas
      academics_textareas.each do |element_id, value|
        element = @browser.textarea(id: element_id.to_s)
        element.scroll.to :center
        element.set value
      end
    end

    def fill_out_highschool_information
      loop do
        select_high_school_state
        next if !select_high_school
        select_high_school_division
        break
      end
    end

    def select_high_school_state
      dropdown = @browser.element(id: 'high_school_state')
      options = dropdown.elements(tag_name: 'option').to_a
      options.shift; options.sample.click
      sleep 1
    end

    def select_high_school
      dropdown = @browser.element(id: 'high_school_name')
      options = dropdown.elements(tag_name: 'option').to_a
      options.shift
      if options.count == 0
        return false
      else
        random_school_name = options.sample
        @selected_high_school_name = random_school_name.text
        random_school_name.click
        sleep 1
      end
    end

    def selected_high_school_name
      @selected_high_school_name
    end

    def select_high_school_division
      dropdown = @browser.element(id: 'high_school_division')
      options = dropdown.elements(tag_name: 'option').to_a
      options.shift; options.sample.click
    end

    def attach_transcript
     # remove previous transcipt
     @browser.element(class: 'remove').click
     @browser.element(class: %w[button button--red js-confirm-delete]).click

     # add transcipt
     @browser.element(class: 'add').click
     sleep 1

     academic_form = @browser.element(class: 'academic-file-form')
     academic_form.scroll.to
     academic_form.text_field(name: 'academic_file[notes]').send_keys @transcript

     path = File.absolute_path('test/c3po/cat.png')
     academic_form = @browser.element(class: 'academic-file-form')
     academic_form.scroll.to
     academic_form.file_field(name: 'academic_file[record]')
     academic_form.file_field(class: 'file').set path

     @browser.element(class: %w[submit add button--primary]).click
    end

    def submit
      @browser.button(value: 'Save').click
    end
  end
end
