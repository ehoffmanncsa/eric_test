# encoding: utf-8

# This class is to create CSV for multiple athletes
class AtheteCSV
  def initialize
  	@headers = ['First Name', 'Last Name', 'Email', 'Primary Team',
  				'Graduation Year', 'Zip Code', 'Phone']
  end

  def get_team_name
    TEDTeamApi.setup
    all_teams = TEDTeamApi.get_all_teams.sample['attributes']['name']
  end

  def generate_data
  	@firstname = MakeRandom.name
  	@lastname = MakeRandom.name
  	@email = MakeRandom.email
  	@grad_yr = MakeRandom.grad_yr
  	@zipcode = MakeRandom.number(5)
  	@phone = MakeRandom.number(10)
    @team = get_team_name
  end

  def make_it
  	CSV.open('athletes.csv', 'w', write_headers: true, headers: @headers) do |csv|
      rand(2 .. 4).times do |i|
      	generate_data
        csv << [@firstname, @lastname, @email, @team, @grad_yr, @zipcode, @phone]
      end
    end
  end
end
