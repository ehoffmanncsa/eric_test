# encoding: utf-8
require_relative '../test_helper'

# TS-65: POS Regression
# UI Test: Purchase Champion + VIP Item (any grad year)
class PurchaseChampionAndVIPItemsTests < Common
  def setup
    super

    # add a new recruit, get back his email address
    _post, post_body = RecruitAPI.new.ppost
    @recruit_email = post_body[:recruit][:athlete_email]

    MSSetup.setup(@browser)
    MSSetup.buy_combo(@recruit_email, 'champion')
  end

  def teardown
    super
  end

  def test_purchase_champion_and_VIP_items
    failure = []

    box1 = @browser.element(:class, 'purchase-summary-js').element(:class, 'package-features')
    title = box1.element(:class, 'title-js').text.downcase
    failure << 'Champion Membership Features not found' unless title.match(/champion membership features/)
    failure << 'Champion Membership Features items not found' if box1.elements(:tag_name, 'li').to_a.empty?

    box2 = @browser.element(:class, 'purchase-summary-js').element(:css, 'div.column.third')
    failure << 'VIP items not found' if box2.elements(:tag_name, 'li').to_a.empty?

    assert_empty failure
  end
end
