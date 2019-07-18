module C3PO
  class MyInformationPageFiller < C3PO::MyInformationPage

    def initial
      super
    end

    def fill_out_textfields(is_prem)
      person_info_textfields.each do |element_id, value|
        next if is_prem && element_id.to_s == 'athlete_email'
        element = @browser.text_field(:id, element_id.to_s)
        element.scroll.to :center
        element.set value
      end
    end

    # This seems to be the only dropdown selection
    # that makes sense to test
    def select_grad_year(grad_yr = nil)
      list = @browser.select_list(:id, 'graduation_year')
      grad_yr.nil? ? list.options.sample.click : (list.select grad_yr)
    end

    def fill_out_personal_statement
      personal_statement_elem = @browser.element(:class, %w(froala-view froala-element not-msie f-basic))
      personal_statement_elem.wd.clear
      personal_statement_elem.send_keys @personal_statement
    end

    def submit
      @browser.button(:value, 'Save').click
    end
  end
end
