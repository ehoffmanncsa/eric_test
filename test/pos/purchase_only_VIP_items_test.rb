# encoding: utf-8
require_relative '../test_helper'

# TS-63: POS Regression
# UI Test: Purchase only VIP items
class PurchaseOnlyVIPItemsTests < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)

    # add a new recruit, get back his email address
    _post, post_body = RecruitAPI.new.ppost
    @recruit_email = post_body[:recruit][:athlete_email]
  end

  def teardown
    @browser.close
  end

  def test_purchase_only_VIP_items
    POSSetup.setup(@browser)
    POSSetup.buy_alacarte(@recruit_email)
    
    UIActions.user_login(@recruit_email)
    @browser.element(:class, 'fa-angle-down').click
    @browser.element(:id, 'secondary-nav-menu').link(:text, 'Membership Info').click

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
