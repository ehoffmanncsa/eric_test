# encoding: utf-8
require_relative '../test_helper'

# TS-63: POS Regression
# UI Test: Purchase only VIP items
class PurchaseOnlyVIPItemsTests < Common
  def setup
    super

    _post, post_body = RecruitAPI.new.ppost
    recruit_email = post_body[:recruit][:athlete_email]
    @clientrms = Default.env_config['clientrms']

    UIActions.user_login(recruit_email)
    MSConvenient.setup(@browser)
    MSConvenient.buy_alacarte_items(recruit_email)
  end

  def teardown
    super
  end

  def check_redirected_to_dashboard
    # this check is for new recruit VIP only purchase - SALES-1427
    current_url = @browser.url
    expected_url = @clientrms['base_url'].delete_suffix('/')
    failure_msg = "User is not redirected to coaching session - current url is #{current_url}"

    assert_equal expected_url, current_url, failure_msg
  end

  def goto_membership_info
    @browser.goto(@clientrms['base_url'] + @clientrms['membership_info'])
  end

  def test_purchase_only_VIP_items
    check_redirected_to_dashboard
    goto_membership_info

    failure = []
    box1 = @browser.element(class: 'purchase-summary-js').element(class: 'package-features')
    title = box1.element(class: 'title-js').text.downcase
    failure << 'Activation Membership Features not found' unless title.match(/activation membership features/)
    failure << 'Activation Membership Features items not found' if box1.elements(tag_name: 'li').to_a.empty?

    box2 = @browser.element(class: 'purchase-summary-js').element(css: 'div.column.third')
    failure << 'VIP items not found' if box2.elements(tag_name: 'li').to_a.empty?

    assert_empty failure
  end
end
