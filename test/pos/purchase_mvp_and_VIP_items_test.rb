# encoding: utf-8
require_relative '../test_helper'

# TS-67: POS Regression
# UI Test: Purchase MVP + VIP Item (any grad year)
class PurchaseMVPAndVIPItemsTests < Minitest::Test
  def setup
    @ui = LocalUI.new(true)
    @browser = @ui.driver

    # add a new recruit, get back his email address
    # cannot add lead with random grad year until packages discount calculation is fixed for any year lower than senior
    _resp, _post, post_body = RecruitAPI.new('senior').ppost
    @recruit_email = post_body[:recruit][:athlete_email]
  end

  def teardown
    @browser.close
  end

  def test_purchase_mvp_and_VIP_items
    POSSetup.setup(@ui)
    POSSetup.buy_combo(@recruit_email, 'mvp')
    
    @ui.user_login(@recruit_email)

    @ui.wait(30) { @browser.find_element(:class, 'fa-angle-down').enabled? }
    @browser.find_element(:class, 'fa-angle-down').click
    @browser.find_element(:id, 'secondary-nav-menu').find_element(:link_text, 'Membership Info').click

    failure = []
    @ui.wait(30) { @browser.find_elements(:tag_name, 'div.row.major').each { |e| e.displayed? } }

    box1 = @browser.find_element(:class, 'purchase-summary-js').find_element(:class, 'package-features')
    title = box1.find_element(:class, 'title-js').text.downcase
    failure << 'MVP Membership Features not found' unless title.match(/mvp membership features/)
    failure << 'MVP Membership Features items not found' if box1.find_elements(:tag_name, 'li').empty?

    box2 = @browser.find_element(:class, 'purchase-summary-js').find_element(:css, 'div.column.third')     
    failure << 'VIP items not found' if box2.find_elements(:tag_name, 'li').empty?
    
    assert_empty failure
  end
end
