# encoding: utf-8
require_relative '../test_helper'

# TS-445
# Redeem/Fulfill VIP Recommendation Engine Test
class RedeemVIPRecommendationTest < Common
  def setup
    super

    #_post, post_body = RecruitAPI.new.ppost
    @recruit_email = "ncsa.automation+1ac1@gmail.com" #post_body[:recruit][:athlete_email]

    UIActions.user_login(@recruit_email)
    MSConvenient.setup(@browser)
  end

  def teardown
    super
  end

  def test_redeem_vip_recommendation
    MSConvenient.buy_alacarte_item_by_name(@recruit_email, "VIP Recommendation Engine")
  end
end
