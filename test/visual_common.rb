# encoding: utf-8
class VisualCommon < Common
 def setup
   config = Default.static_info
   @viewports = [
     { ipad: config['viewport']['ipad'] },
     { iphone: config['viewport']['iphone'] },
     { desktop: config['viewport']['desktop'] }
   ]
   @eyes = Applitool.new 'Content'
   super
 end

 def teardown
   super
 end
end
