# encoding: utf-8
class Common < Minitest::Test
 def setup
   Selenium::WebDriver::Firefox::Binary.path="/usr/lib/firefox"
   # @ui = UI.new 'docker', 'firefox'
   @ui = UI.new 'local', 'firefox'
   @browser = @ui.driver
   UIActions.setup(@browser)
 end

 def teardown
   @browser.close
 end
end
