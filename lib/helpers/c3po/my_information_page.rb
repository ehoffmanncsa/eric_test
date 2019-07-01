module C3PO
  class MyInformationPage
    attr_reader :athlete_email
    attr_reader :first_name
    attr_reader :last_name
    attr_reader :athlete_phone
    attr_reader :athlete_secondary_phone
    attr_reader :parent1_first_name
    attr_reader :parent1_last_name
    attr_reader :parent1_phone
    attr_reader :parent1_secondary_phone
    attr_reader :parent1_email
    attr_reader :parent2_first_name
    attr_reader :parent2_last_name
    attr_reader :parent2_phone
    attr_reader :parent2_secondary_phone
    attr_reader :parent2_email
    attr_reader :address
    attr_reader :city
    attr_reader :zip
    attr_reader :preferred_major

    def initialize(browser)
      @browser = browser
    end

    def person_info_textfields
      make_data

      {
        first_name: @first_name,
        last_name: @last_name,
        athlete_phone: @athlete_phone,
        athlete_secondary_phone: @athlete_secondary_phone,
        parent1_first_name: @parent1_first_name,
        parent1_last_name: @parent1_last_name,
        parent1_phone: @parent1_phone,
        parent1_secondary_phone: @parent1_secondary_phone,
        parent1_email: @parent1_email,
        parent2_first_name: @parent2_first_name,
        parent2_last_name: @parent2_last_name,
        parent2_phone: @parent2_phone,
        parent2_secondary_phone: @parent2_secondary_phone,
        parent2_email: @parent2_email,
        address: @address,
        city: @city,
        zip: @zip,
        preferred_major: @preferred_major
      }
    end

    private

    def make_data
      @first_name = MakeRandom.first_name
      @last_name = MakeRandom.last_name
      @athlete_phone = MakeRandom.phone_number
      @athlete_secondary_phone = MakeRandom.phone_number
      @parent1_first_name = MakeRandom.first_name
      @parent1_last_name = MakeRandom.last_name
      @parent1_phone = MakeRandom.phone_number
      @parent1_secondary_phone = MakeRandom.phone_number
      @parent1_email = MakeRandom.fake_email
      @parent2_first_name = MakeRandom.first_name
      @parent2_last_name = MakeRandom.last_name
      @parent2_phone = MakeRandom.phone_number
      @parent2_secondary_phone = MakeRandom.phone_number
      @parent2_email = MakeRandom.fake_email
      @address = MakeRandom.address
      @city = MakeRandom.city
      @zip = MakeRandom.zip_code
      @preferred_major = MakeRandom.major
    end
  end
end
