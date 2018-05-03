require_relative '../../test/test_helper'

# Common actions that UI tests perform
module UIActions
  def self.setup(browser)
    @browser = browser
    @config = Default.env_config
  end

  def self.get_subfooter
    @browser.find_element(:class, 'subfooter')
  end

  def self.check_subfooter_msg(subfooter, viewport_size)
    cls = ''; phone_number = ''; failure = []
    case viewport_size
      when 'iphone'
        phone_number = '855-410-6272'
        cls = 'tablet-hide'
      else
        phone_number = '866-495-5172'
        cls = 'tablet-show'
    end

    subfooter_msg = subfooter.find_element(:class, cls)
    raise "#{viewport_size} - subfooter message not found" unless subfooter_msg.displayed?
    raise "#{viewport_size} - wrong subfooter phone number" unless subfooter_msg.text.include? phone_number
  end
end
