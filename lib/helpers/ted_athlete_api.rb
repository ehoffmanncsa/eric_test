require_relative '../../test/test_helper'

# Common actions that UI tests perform
module TEDAthleteApi
  class << self
    attr_accessor :org_id
    attr_accessor :org_name
    attr_accessor :admin_api
    attr_accessor :coach_api
  end

  def self.setup
    # default to Awesome Volleyball org and Otto Mation PA
    @admin_api ||= TEDApi.new('admin')
    @coach_api ||= TEDApi.new('coach')
    @org_id ||= '15'
    @org_name ||= 'Awesome Volleyball'
  end

  def self.add_athlete(body)
    endpoint = "organizations/#{@org_id}/athletes"
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
          team: { data: { type: 'teams', id: id } } 
        },
        type: 'athletes'
      }
    }

    api.create(endpoint, body)['data']
  end

  def self.get_all_athletes
    endpoint = "organizations/#{@org_id}/athletes"
    @admin_api.read(endpoint)['data']
  end

  def self.delete_athlete(id)
    endpoint = "athletes/#{id}"
    @admin_api.delete(endpoint)['data']
  end

  def self.delete_all_athletes
    athletes = get_all_athletes
    athletes.each { |athlete| delete_athlete(athlete['id']) }
  end
end
