# encoding: utf-8
require_relative '../test_helper'

# TS-63: POS Regression
# UI Test: Purchase only VIP items
class PurchaseOnlyVIPItemsTests < Common
  def setup
    super

    _post, post_body = RecruitAPI.new.ppost
    recruit_email = post_body[:recruit][:athlete_email]

    UIActions.user_login(recruit_email)

    MSSetup.setup(@browser)

    MSConvenient.setup(@browser)
    MSConvenient.buy_alacarte(recruit_email)
    goto_membership_info
  end

  def teardown
    super
  end

  def goto_membership_info
    clientrms = Default.env_config['clientrms']
    @browser.goto(clientrms['base_url']+ clientrms['membership_info'])
  end

  def test_purchase_only_VIP_items
    failure = []

    box1 = @browser.element(:class, 'purchase-summary-js').element(:class, 'package-features')
    title = box1.element(:class, 'title-js').text.downcase
    failure << 'Activation Membership Features not found' unless title.match(/activation membership features/)
    failure << 'Activation Membership Features items not found' if box1.elements(:tag_name, 'li').to_a.empty?

    box2 = @browser.element(:class, 'purchase-summary-js').element(:css, 'div.column.third')
    failure << 'VIP items not found' if box2.elements(:tag_name, 'li').to_a.empty?

    assert_empty failure
  end
end
