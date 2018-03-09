require_relative '../../test/test_helper'

# Common team actions that TED tests perform
module TEDTeamApi
  class << self
    attr_accessor :org_id
    attr_accessor :admin_api
  end

  def self.setup
    # default to Awesome Volleyball org and Otto Mation PA
    @admin_api ||= TEDApi.new('admin')
    @org_id ||= '15'
  end

  def self.get_all_teams
    endpoint = "organizations/#{@org_id}/teams"
    @admin_api.read(endpoint)['data']
  end

  def self.get_team_by_id(id)
    endpoint = "teams/#{id}"
    @admin_api.read(endpoint)['data']
  end

  def self.delete_team(id)
    endpoint = "teams/#{id}/delete_team"
    @admin_api.delete(endpoint)['data']
  end

  def self.delete_all_teams
    teams = get_all_teams
    teams.each { |team| delete_team(team['id']) }
  end
end
