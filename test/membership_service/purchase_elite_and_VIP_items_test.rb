# encoding: utf-8
require_relative '../test_helper'

# TS-66, TS-446, TS-468, TS-469, TS-473
# Purchase Elite + VIP Item(s) (any grad year)
class PurchaseEliteAndVIPItemsTests < Common
  def setup
    super

    _post, post_body = RecruitAPI.new.ppost
    recruit_email = post_body[:recruit][:athlete_email]

    UIActions.user_login(recruit_email)

    MSConvenient.setup(@browser)
    @vip_items_picked = MSConvenient.buy_combo(recruit_email, 'elite')
  end

  def teardown
    super
  end

  def test_purchase_elite_and_VIP_items
    failure = []

    box1 = @browser.element(:class, 'purchase-summary-js').element(:class, 'package-features')
    title = box1.element(:class, 'title-js').text.downcase
    failure << 'Elite Membership Features not found' unless title.match(/elite membership features/)
    failure << 'Elite Membership Features items not found' if box1.elements(:tag_name, 'li').to_a.empty?

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
