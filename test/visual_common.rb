# encoding: utf-8
class VisualCommon < Common
  def setup
    super

    @viewports = [
     { ipad: Default.static_info['viewport']['ipad'] },
     { iphone: Default.static_info['viewport']['iphone'] },
     { desktop: Default.static_info['viewport']['desktop'] }
    ]

    DailyMonitor.setup(@browser)
    @eyes = Applitool.new 'Content'
    @driver = @browser.driver
  end

  def open_eyes(test_name, size)
    @eyes.open @driver, test_name, DailyMonitor.width(size), DailyMonitor.height(size)
  end

  def teardown
   super
  end
end
