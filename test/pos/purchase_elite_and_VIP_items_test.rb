# encoding: utf-8
require_relative '../test_helper'

# TS-66: POS Regression
# UI Test: Purchase Elite + VIP Item (any grad year)
class PurchaseEliteAndVIPItemsTests < Minitest::Test
  def setup
    @ui = LocalUI.new(true)
    @browser = @ui.driver

    # add a new recruit, get back his email address and username
    _resp, _post, @username = RecruitAPI.new.ppost
    @recruit_email = "#{@username}@ncsasports.org"
  end

  def teardown
    @browser.close
  end

  def test_purchase_elite_and_VIP_items
    POSSetup.new.buy_combo(@recruit_email, @username, 'elite')
    
    @ui.user_login(@username)

    @ui.wait(30) { @browser.find_element(:class, 'fa-angle-down').enabled? }
    @browser.find_element(:class, 'fa-angle-down').click
    @browser.find_element(:id, 'secondary-nav-menu').find_element(:link_text, 'Membership Info').click

    failure = []
    @ui.wait(30) { @browser.find_elements(:tag_name, 'div.row.major').each { |e| e.displayed? } }

    box1 = @browser.find_element(:class, 'purchase-summary-js').find_element(:class, 'package-features')
    title = box1.find_element(:class, 'title-js').text.downcase
    failure << 'Elite Membership Features not found' unless title.match(/elite membership features/)
    failure << 'Elite Membership Features items not found' if box1.find_elements(:tag_name, 'li').empty?

    box2 = @browser.find_element(:class, 'purchase-summary-js').find_element(:css, 'div.column.third')     
    failure << 'VIP items not found' if box2.find_elements(:tag_name, 'li').empty?
    
    assert_empty failure
  end
end
