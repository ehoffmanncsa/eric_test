# encoding: utf-8

# This class is to create CSV for multiple roster athletes for Coach Packet upload
# these athltes have enough data in the csv to create a profile in client rms.
class ScheduleCSV
  def initialize
  	@headers = ['team_one','team_one_org','team_two','team_two_org','name','sport_name',
                'venue','location','time','date','team_one_division','team_two_division']
  end

  def generate_data
    @team_one = AthleticEventApi.team_name
    @team_one_org =  AthleticEventApi.org_name
    @team_two = AthleticEventApi.team_name
    @team_two_org =  AthleticEventApi.org_name
    @name = "#{@team_one_org}" + "#{@team_one}" "vs" "#{@team_two_org}" + "#{@team_two}"
    @sport_name = "Men's Basketball"
    @venue = ['testvenue1', 'testvenue2'].sample
    @location =  AthleticEventApi.locations
    @time = AthleticEventApi.game_time
    @date = AthleticEventApi.schedule_date
    @team_one_division = "#{@team_one}"
    @team_two_division = "#{@team_two}"
  end

  def make_it
  	CSV.open('schedule.csv', 'w', write_headers: true, headers: @headers) do |csv|
      4.times do |i|
      	generate_data
        csv << [@team_one,@team_one_org,@team_two,@team_two_org,@name,@sport_name,
                @venue,@location,@time,@date,@team_one_division,@team_two_division]
      end
    end
  end
end
