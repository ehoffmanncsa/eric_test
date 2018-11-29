require_relative '../../test/test_helper'

# Add teams of available sports to org
class AddTeams
  def initialize(org_id)
    @api = TEDApi.new('partner')
    @org_id = (org_id.nil?) ? get_awesome_sauce_id : org_id
  end

  def get_awesome_sauce_id
    @api.read('partners/1/organizations?contracts_status=' \
      '&text_query=Awesome Sauce&org_type=&page=1')['data'][0]['id']
  end

  def get_org_sports
    endpoint = "organizations/#{@org_id}/organization_sports"
    @api.read(endpoint)['data']
  end

  def create_teams
    endpoint = "organizations/#{@org_id}/teams"
    sports = get_org_sports
    sports.each do |sport|
      body = {
        data: {
          attributes: { name: sport['attributes']['sport-name'] },
          relationships: {
            organization: { data: { type: 'organizations', id: @org_id } },
            organization_sport: {
              data: { type: 'organization_sports', id: sport['id'] }
            }
          }
        }
      }.to_json

      resp = @api.create(endpoint, body)
    end
  end
end

org_id = ARGV[0]
AddTeams.new(org_id).create_teams
