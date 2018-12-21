# encoding: utf-8
class Common < Minitest::Test
 def setup
   @ui = UI.new 'local', 'firefox'
   # @ui = UI.new 'docker', 'firefox'
   @browser = @ui.driver
   UIActions.setup(@browser)
 end

 def teardown
   @browser.close
 end
end
