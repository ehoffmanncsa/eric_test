require_relative '../../test/test_helper'

# Add teams of available sports to org
class AddTeams
  def initialize
    @api = TEDApi.new('admin')
  end

  def get_org_sports
    endpoint = 'organizations/440/organization_sports'
    @api.read(endpoint)['data']
  end

  def create_teams
    endpoint = 'organizations/440/teams'
    sports = get_org_sports
    sports.each do |sport|
      body = {
        data: {
          attributes: { name: sport['attributes']['sport-name'] },
          relationships: {
            organization: { data: { type: 'organizations', id: '440' } },
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

AddTeams.new.create_teams