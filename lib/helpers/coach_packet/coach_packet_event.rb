module CP
  class CoachPacketEvent
    attr_reader :name
    attr_reader :website
    attr_reader :logo_url
    attr_reader :registration_link
    attr_reader :age_range
    attr_reader :description
    attr_reader :start_date
    attr_reader :start_time
    attr_reader :end_date
    attr_reader :end_time
    attr_reader :contact_name
    attr_reader :contact_email
    attr_reader :city

    def initialize(browser)
      @browser = browser
      make_data
    end

    def event_textfields
      {
        name: @name,
        website: @website,
        logo_url: @logo_url,
        registration_link: @registration_link,
        age_range: @age_range,
        description: @description,
        start_time: @start_time,
        end_time: @end_time,
        point_of_contact_name: @contact_name,
        point_of_contact_email: @contact_email,
        city: @city
      }
    end

    def event_datefields
      {
        start_date: @start_date,
        end_date: @end_date
      }
    end

    private

    def make_data
      @name = MakeRandom.company_name
      @website = MakeRandom.url
      @logo_url = AthleticEventApi.logo_urls
      @registration_link = MakeRandom.url
      @age_range = MakeRandom.age_range
      @description = MakeRandom.lorem(rand(1 .. 4))
      @start_date = AthleticEventApi.admin_event_date
      @start_time = AthleticEventApi.game_time
      @end_date = AthleticEventApi.admin_event_date(rand(3 .. 4))
      @end_time = AthleticEventApi.game_time
      @contact_name = "#{MakeRandom.first_name}" + "#{MakeRandom.last_name}"
      @contact_email = MakeRandom.fake_email
      @city = MakeRandom.city
      @address = MakeRandom.address
      @zip = MakeRandom.zip_code
    end
  end
end
