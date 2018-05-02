require_relative '../../test/test_helper'

# Common actions with coach that TED tests perform
module TEDCoachApi
  class << self
    attr_accessor :partner_api
    attr_accessor :coach_api
    attr_accessor :org_id
  end

  def self.setup
    # default to Otto Mation PA
    @partner_api ||= TEDApi.new('partner')
    @org_id ||= '440'
  end

  def self.get_all_coaches(coach = false)
    endpoint = "organizations/#{@org_id}/coaches"
    api = coach ? @coach_api : @partner_api
    api.read(endpoint)['data']
  end

  def self.get_coach_by_id(coach_id, coach = false)
    endpoint = "coaches/#{coach_id}"
    api = coach ? @coach_api : @partner_api
    api.read(endpoint)['data']
  end

  def self.get_coach_by_email(coach_email, coach = false)
    all_coaches = get_all_coaches(coach)
    all_coaches.detect { |coach| coach['attributes']['email'].eql? coach_email }
  end

  def self.delete_coach(coach_id, coach = false)
    endpoint = "coaches/#{coach_id}"
    api = coach ? @coach_api : @partner_api
    api.delete(endpoint)['data']
  end
end
