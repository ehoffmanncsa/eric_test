require_relative '../../test/test_helper'

# Common actions that Daily Monitor UI tests perform
module DailyMonitor
  def self.setup(browser)
    @browser = browser
    @config = Default.env_config
  end

  def self.subfooter
    @browser.element(:class, 'subfooter')
  end

  def self.check_subfooter_msg(viewport_size)
    cls = ''; phone_number = ''; failure = []
    case viewport_size
      when 'iphone'
        phone_number = '855-410-6272'
        cls = 'tablet-hide'
      else
        phone_number = '866-495-5172'
        cls = 'tablet-show'
    end

    subfooter_msg = subfooter.element(:class, cls)
    raise "#{viewport_size} - subfooter message not found" unless subfooter_msg.present?
    raise "#{viewport_size} - wrong subfooter phone number" unless subfooter_msg.text.include? phone_number
  end

  def self.load_partner_list_block
    view = @browser.div(:id, 'block-views-partner-list-block')
    view.scroll_into_view
    #UIActions.wait_for_spinner
    # view.elements(:class, 'views-field').each |logo|
    #   Watir::Wait.until { logo.present? }
    # end
  end
end
