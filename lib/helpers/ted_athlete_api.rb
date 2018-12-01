require_relative '../../test/test_helper'

# Common actions that UI tests perform
module TEDAthleteApi
  class << self
    attr_accessor :org_id
    attr_accessor :org_name
    attr_accessor :partner_api
    attr_accessor :coach_api
    attr_accessor :athlete_id
  end

  def self.setup
    # default to Awesome Volleyball org and Otto Mation PA
    @partner_api ||= TEDApi.new('partner')
    @coach_api ||= TEDApi.new('prem_coach')
    @org_id ||= '728'
    @org_name ||= 'Awesome Sauce'
  end

  def self.add_athlete(body = nil, coach = false)
    endpoint = "organizations/#{@org_id}/athletes"
    if body.nil?
      TEDTeamApi.setup
      TEDTeamApi.org_id = @org_id
      body = {
        data: {
          attributes: {
            email: MakeRandom.email,
            first_name: MakeRandom.first_name,
            graduation_year: MakeRandom.grad_yr,
            last_name: MakeRandom.last_name,
            phone: MakeRandom.phone_number,
            zip_code: MakeRandom.zip_code
          },
          relationships: {
            team: { data: { type: 'teams', id: TEDTeamApi.get_random_team_id } }
          },
          type: 'athletes'
        }
      }.to_json
    end

    api = coach ? @coach_api : @partner_api
    api.create(endpoint, body)['data']
  end

  def self.get_athlete_by_id(athlete_id, coach = false)
    endpoint = "athletes/#{athlete_id}"
    api = coach ? @coach_api : @partner_api
    api.read(endpoint)['data']
  end

  def self.get_athlete_by_email(email, coach = false)
    all_athletes = get_all_athletes(coach)
    all_athletes.detect { |athlete| athlete['attributes']['profile']['email'].eql? email }
  end

  def self.get_athlete_id_by_email(email, coach = false)
    athlete = get_athlete_by_email(email, coach)
    athlete['id']
  end

  def self.get_all_athletes(coach = false)
    endpoint = "organizations/#{@org_id}/athletes"
    api = coach ? @coach_api : @partner_api
    api.read(endpoint)['data']
  end

  def self.delete_athlete(id, coach = false)
    endpoint = "athletes/#{id}"
    api = coach ? @coach_api : @partner_api
    api.delete(endpoint)['data']
  end

  def self.delete_all_athletes(coach = false)
    athletes = get_all_athletes
    athletes.each { |athlete| delete_athlete(athlete['id'], coach) }
  end

  def self.send_invite_email(id = nil)
    id = @athlete_id if id.nil?
    endpoint = "athletes/#{id}/invite_single_athlete"
    @partner_api.patch(endpoint, nil)
  end

  def self.find_athletes_by_status(status)
    endpoint = "organizations/#{@org_id}/athletes"
    all_athletes = get_all_athletes
    all_athletes.select do |athlete|
      athlete['attributes']['invite-status'] == status && athlete['attributes']['deleted'] == false
    end
  end
end
