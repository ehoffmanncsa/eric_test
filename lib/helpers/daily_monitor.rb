require_relative '../../test/test_helper'

# Common actions that Daily Monitor UI tests perform
module DailyMonitor
  def self.setup(browser)
    @browser = browser
    @pages = Default.static_info['pages']
  end

  def self.width(size)
    size.values[0]['width']
  end

  def self.height(size)
    size.values[0]['height']
  end

  def self.goto_page(page)
    @browser.goto @pages[page]['url']
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

  def self.hamburger_menu
    # check iphone and hamburger exists
    unless @browser.element(:id, 'block-block-62').present? || @browser.element(:id, 'block-block-63').present?
      raise '[ERROR] Tablet and Hamburger not found'
    end

    @browser.element(:class, 'fa-bars')
  end

  def self.get_url_response(url)
    begin
      resp = RestClient::Request.execute(method: :get, url: url)
    rescue => e
      return "[ERROR] #{url} - #{e}"
    end

    resp.code
  end
end
