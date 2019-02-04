require_relative '../../test/test_helper'

# Add teams of available sports to org
class DeleteTEDAthleteNoTeam
  def initialize(org_id)
    TEDAthleteApi.setup
    @org_id = org_id
  end

  def find_athletes_no_teams
    orphans = []
    athetes = TEDAthleteApi.get_all_athletes
    athetes.each do |athlete|
      orphans << athlete['id'] if athlete['attributes']['primary-team-name'].nil?
    end

    orphans
  end

  def delete_them
    athlete_ids = find_athletes_no_teams
    athlete_ids.each do |id|
      TEDAthleteApi.delete_athlete(id)
    end
  end
end

org_id = ARGV[0]
DeleteTEDAthleteNoTeam.new(org_id).delete_them
