# encoding: utf-8

# This class is to create CSV for multiple athletes
class AthleteCSV
  def initialize
  	@headers = ['First Name', 'Last Name', 'Email', 'Primary Team',
  				'Graduation Year', 'Zip Code', 'Phone', 'Parent First Name', 'Parent Last Name', 'Parent Email', 'Parent Phone']
  end

  def get_team_name
    TEDTeamApi.setup
    all_teams = TEDTeamApi.get_all_teams.sample['attributes']['name']
  end

  def generate_data
  	@firstname = MakeRandom.first_name
  	@lastname = MakeRandom.last_name
  	@email = MakeRandom.email
  	@grad_yr = MakeRandom.grad_yr
  	@zipcode = MakeRandom.zip_code
  	@phone = MakeRandom.phone_number
    @team = get_team_name
    @parentfirstname = MakeRandom.first_name
    @parentlastname = MakeRandom.last_name
    @parentemail = MakeRandom.email
    @parentphone = MakeRandom.phone_number
  end

  def make_it
  	CSV.open('athletes.csv', 'w', write_headers: true, headers: @headers) do |csv|
      rand(2 .. 4).times do |i|
      	generate_data
        csv << [@firstname, @lastname, @email, @team, @grad_yr, @zipcode, @phone, @parentfirstname, @parentlastname, @parentemail, @parentphone]
      end
    end
  end
end
