# encoding: utf-8
require_relative '../test_helper'

# TS-67: POS Regression
# UI Test: Purchase MVP + VIP Item (any grad year)
class PurchaseMVPAndVIPItemsTests < Common
  def setup
    super

    _post, post_body = RecruitAPI.new.ppost
    recruit_email = post_body[:recruit][:athlete_email]

    UIActions.user_login(recruit_email)

    MSConvenient.setup(@browser)
    @vip_items_picked = MSConvenient.buy_combo(recruit_email, 'mvp')
  end

  def teardown
    super
  end

  def test_purchase_mvp_and_VIP_items
    failure = []

    box1 = @browser.element(:class, 'purchase-summary-js').element(:class, 'package-features')
    title = box1.element(:class, 'title-js').text.downcase
    failure << 'MVP Membership Features not found' unless title.match(/mvp membership features/)
    failure << 'MVP Membership Features items not found' if box1.elements(:tag_name, 'li').to_a.empty?

    box2 = @browser.element(:class, 'purchase-summary-js').element(:css, 'div.column.third')
    failure << 'VIP items not found' if box2.elements(:tag_name, 'li').to_a.empty?

    box2_items = []
    box2.elements(:tag_name, 'li').each { |item| box2_items << item.text.split(' ')[1..-1].join(' ') }
    @vip_items_picked.each do |item|
      failure << "VIP item #{item} not found in summary." unless box2_items.include? item
    end

    assert_empty failure
  end
end
