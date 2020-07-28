# encoding: utf-8
require_relative '../test_helper'

# TS-66, TS-446, TS-468, TS-469, TS-473
# Purchase Elite + VIP Item(s) (any grad year)
class PurchaseEliteAndVIPItemsTests < Common
  def setup
    super

    _post, post_body = RecruitAPI.new.ppost
    @recruit_email = post_body[:recruit][:athlete_email]

    UIActions.user_login(@recruit_email)
    MSConvenient.setup(@browser)
  end

  def teardown
    super
  end

  def goto_membership_info
    clientrms = Default.env_config['clientrms']
    @browser.goto(clientrms['base_url']+ clientrms['membership_info'])
    sleep 2
  end

  def check_redirected_to_coachsession
    # this check is only for premium enrollment - SALES-1427
    current_url = @browser.url
    failure_msg = "User is not redirected to coaching session - current url is #{current_url}"
    assert_includes current_url, 'coaching_session_requests/new', failure_msg
  end

  def check_membership_features
    failure = []
    membership_section = @browser.element(:class, 'purchase-summary-js').element(:class, 'package-features')
    title = membership_section.element(:class, 'title-js').text.downcase
    failure << 'Elite Membership Features not found' unless title.match(/elite membership features/)
    failure << 'Elite Membership Features items not found' if membership_section.elements(:tag_name, 'li').to_a.empty?

    assert_empty failure
  end

  def check_vip_features
    vip_section = @browser.element(:class, 'purchase-summary-js').element(:css, 'div.column.third')
    refute_empty vip_section.elements(:tag_name, 'li').to_a, 'VIP items not found'

    failure = []
    vip_section_items = []
    vip_section.elements(:tag_name, 'li').each do |item|
      formatted_package_name = item.text.split(' ')[1..-1].join(' ')
      formatted_package_name.delete_suffix!('s') if formatted_package_name == 'VIP Coachings'

      vip_section_items << formatted_package_name
    end
    @vip_items_picked.each do |item|
      item.delete_suffix!('s') if item == 'VIP Coachings'
      failure << "VIP item #{item} not found in summary." unless vip_section_items.include? item
    end

    assert_empty failure
  end

  def test_purchase_elite_and_VIP_items
    @vip_items_picked = MSConvenient.buy_combo(@recruit_email, 'elite')

    check_redirected_to_coachsession

    goto_membership_info
    #check_membership_features
    check_vip_features
  end
end
