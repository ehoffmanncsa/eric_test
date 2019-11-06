# encoding: utf-8

# This class is to create CSV for a roster athlete Austin Everhart,
# this will match his client rms profile.
class RosterMatchCSV
  def initialize
  	@headers = ['sport_name', 'role', 'position_primary','athlete_first_name', 'athlete_last_name',
                'graduation_year', 'jersey_number','athlete_email', 'org_name', 'team_name']
  end

  def generate_data
    @sport_name = "Men's Basketball"
    @role = 'Athlete'
    @athlete_first_name =  'Austin'
    @athlete_last_name = 'Everhart'
    @position_primary = "Power Forward"
    @graduation_year = '2019'
    @jersey_number = MakeRandom.number(2)
    @athlete_email = 'AustinEverhart2019@test.com'
    @org_name = MakeRandom.name
    @team_name = '16U'
  end

  def make_it
  	CSV.open('rostermatch.csv', 'w', write_headers: true, headers: @headers) do |csv|
      	generate_data
        csv << [@sport_name, @role, @position_primary, @athlete_first_name, @athlete_last_name,
                @graduation_year, @jersey_number, @athlete_email, @org_name, @team_name]
    end
  end
end
