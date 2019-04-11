# encoding: utf-8
require_relative '../test_helper'

# PREM-3068
# Make sure helpscout link in admin menu has correct mailbox slug

class HelpScoutMailboxSlugTest < Common
  def setup
    super

    C3PO.setup(@browser)
  end

  def teardown
    super
  end

  def test_helpscout_mailbox_slug
    impersonate
    open_admin_menu
    inspect_email_link
  end

  private

  def impersonate
    athlete_client_id = Default.env_config['ops_messaging']['client_id']
    C3PO.impersonate(athlete_client_id)
  end

  def gear
    @browser.span(:'data-jq-dropdown', "#admin-menu")
  end

  def open_admin_menu
    gear.click
    sleep 1
  end

  def admin_menu
    @browser.div(:id, 'admin-menu')
  end

  def find_helpscout_email_link
    email_link = nil

    admin_menu.links(:text, /Email/).each do |link|
      if link.attribute_value('href').include? 'secure.helpscout.net'
        email_link = link.attribute_value('href')
      end
    end

    raise '[ERROR] Helpscout email link not found.' if email_link.nil?

    email_link
  end

  def inspect_email_link
    email_link = find_helpscout_email_link
    expected_email_slug = Default.env_config['helpscout']['coach_ehoffman_mailbox_slug']
    message = 'Helpscout email link does not include expected email slug.'

    assert_includes email_link, expected_email_slug, message
  end
end
