# encoding: utf-8

# This class is to create CSV for multiple roster athletes for Coach Packet upload
# these athltes have enough data in the csv to create a profile in client rms.
class RosterRMSCSV
  def initialize
  	@headers = ['sport_name', 'role', 'position_primary', 'high_school_name','athlete_first_name', 'athlete_last_name',
                'parent_first_name', 'parent_last_name', 'parent_email', 'parent_phone',
                'graduation_year', 'jersey_number', 'zip', 'athlete_phone', 'athlete_email',
                'org_name', 'team_name', 'state_code']
  end

  def generate_data
    @sport_name = "Men's Basketball"
    @role = 'Athlete'
    @athlete_first_name =  MakeRandom.first_name
    @athlete_last_name = MakeRandom.last_name
    @position_primary = AthleticEventApi.position
    @high_school_name = MakeRandom.high_school
    @parent_first_name =  MakeRandom.first_name
    @parent_last_name = MakeRandom.last_name
    @parent_email = MakeRandom.fake_email
    @parent_phone = MakeRandom.phone_number
    @graduation_year = MakeRandom.grad_yr
    @jersey_number = MakeRandom.number(2)
    @zip = MakeRandom.zip_code
    @athlete_phone = MakeRandom.phone_number
    @athlete_email = MakeRandom.fake_email
    @org_name = AthleticEventApi.org_name
    @team_name = AthleticEventApi.team_name
    @state_code = MakeRandom.state
  end

  def make_it
  	CSV.open('roster_create_rms.csv', 'w', write_headers: true, headers: @headers) do |csv|
      rand(10 .. 16).times do |i|
      	generate_data
        csv << [@sport_name, @role, @position_primary, @high_school_name, @athlete_first_name, @athlete_last_name,
                @parent_first_name, @parent_last_name, @parent_email, @parent_phone,
                @graduation_year, @jersey_number, @zip, @athlete_phone, @athlete_email,
                @org_name, @team_name, @state_code]
      end
    end
  end
end
