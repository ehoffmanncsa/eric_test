require_relative '../../test/test_helper'

# Common actions that UI tests perform
module TEDAthleteApi
  class << self
    attr_accessor :org_id
    attr_accessor :org_name
    attr_accessor :admin_api
    attr_accessor :coach_api
    attr_accessor :athlete_id
  end

  def self.setup
    # default to Awesome Volleyball org and Otto Mation PA
    @admin_api ||= TEDApi.new('admin')
    @coach_api ||= TEDApi.new('coach')
    @org_id ||= '440'
    @org_name ||= 'Awesome Sauce'
  end

  def self.get_team_id
    TEDTeamApi.setup
    TEDTeamApi.org_id = @org_id
    random_team = TEDTeamApi.get_all_teams.sample

    random_team['id']
  end

  def self.add_athlete(body = nil, coach = false)
    endpoint = "organizations/#{@org_id}/athletes"
    if body.nil?
      body = {
        data: {
          attributes: {
            email: MakeRandom.email,
            first_name: MakeRandom.name,
            graduation_year: MakeRandom.year,
            last_name: MakeRandom.name,
            phone: MakeRandom.number(10),
            zip_code: MakeRandom.number(5)
          },
          relationships: {
            team: { data: { type: 'teams', id: get_team_id } } 
          },
          type: 'athletes'
        }
      }.to_json
    end

    api = coach ? @coach_api : @admin_api
    api.create(endpoint, body)['data']
  end

  def self.get_athlete_by_id(athlete_id, coach = false)
    endpoint = "athletes/#{athlete_id}"
    api = coach ? @coach_api : @admin_api
    api.read(endpoint)['data']
  end

  def self.get_athlete_by_email(email, coach = false)
    all_athletes = get_all_athletes(coach)
    all_athletes.detect { |athlete| athlete['attributes']['profile']['email'].eql? email }
  end

  def self.get_all_athletes(coach = false)
    endpoint = "organizations/#{@org_id}/athletes"
    api = coach ? @coach_api : @admin_api
    api.read(endpoint)['data']
  end

  def self.delete_athlete(id, coach = false)
    endpoint = "athletes/#{id}"
    api = coach ? @coach_api : @admin_api
    api.delete(endpoint)['data']
  end

  def self.delete_all_athletes(coach = false)
    athletes = get_all_athletes
    athletes.each { |athlete| delete_athlete(athlete['id'], coach) }
  end

  def self.send_invite_email(id = nil)
    id = @athlete_id if id.nil?
    endpoint = "athletes/#{id}/invite_single_athlete"
    @admin_api.patch(endpoint, nil)
  end
end
