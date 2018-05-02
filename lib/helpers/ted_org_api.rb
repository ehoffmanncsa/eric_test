require_relative '../../test/test_helper'

# Common actions with organization that TED tests perform
module TEDOrgApi
  class << self
    attr_accessor :partner_api
    attr_accessor :org_id
  end

  def self.setup
    # default to Otto Mation PA
    @partner_api ||= TEDApi.new('partner')
  end

  def self.create_org(body = nil)
    endpoint = 'partners/1/organizations'
    sport_id = Default.static_info['sport_ids'].sample.to_s

    if body.nil?
      body = {
        data: {
          attributes: {
            address: '1234 El Taco',
            city: 'Chicago',
            email: MakeRandom.email,
            first_name: MakeRandom.name,
            last_name: MakeRandom.name,
            name: MakeRandom.name,
            phone: MakeRandom.number(10),
            state: 'IL',
            type: 'Organization',
            website: '',
            zip_code: MakeRandom.number(5)
          },
          relationships: {
            partner: { data: { type: 'partners' } },
            sport: { data: { type: 'sports', id: sport_id } }
          },
          type: 'organizations'
        }
      }.to_json
    end

    @partner_api.create(endpoint, body)['data']
  end

  def self.delete_org(org_id = nil)
    @org_id ||= org_id
    prep_conditions
    endpoint = "organizations/#{@org_id}"
    @partner_api.delete(endpoint)
  end

  def self.prep_conditions
    # In order to delete org, must satisfy
    # 0 contract, 0 team, 0 athlete
    endpoint = "organizations/#{@org_id}"
    data = @partner_api.read(endpoint)['data']['attributes']
    cleanse_athlete unless data['number-of-athletes'] == 0
    cleanse_team unless data['number-of-teams'] == 0
    cleanse_contract unless data['number-of-contracts'] == 0
  end

  def self.cleanse_athlete
    TEDAthleteApi.partner_api = @partner_api
    TEDAthleteApi.org_id = @org_id
    TEDAthleteApi.delete_all_athletes
  end

  def self.cleanse_team
    TEDTeamApi.partner_api = @partner_api
    TEDTeamApi.org_id = @org_id
    TEDTeamApi.delete_all_teams
  end

  def self.cleanse_contract
    TEDContractApi.partner_api = @partner_api
    TEDContractApi.org_id = @org_id
    TEDContractApi.delete_all_contracts
  end
end
