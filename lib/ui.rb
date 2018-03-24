# encoding: utf-8
require 'watir'

class UI
  attr_accessor :driver
  attr_accessor :wait
  attr_accessor :browser

  def initialize hub, browser = nil
    @config = YAML.load_file('config/config.yml')
    @creds = YAML.load_file('config/.creds.yml')

    self.browser = browser.nil? ? 'firefox' : browser
    case hub
      when 'docker' then docker
      when 'browserstack' then browserstack
      when 'local' then local
    end
  end

  def docker
    opts = { timeout: 120, url: 'http://localhost:4444/wd/hub' }
    self.driver = Watir::Browser.new :"#{browser}", opts
    self.driver.driver.file_detector = lambda do |args|
      # args => ["/path/to/file"]
      str = args.first.to_s
      str if File.exist?(str)
    end

    self.driver
  end

  def browserstack
    caps = Selenium::WebDriver::Remote::Capabilities.new
    caps['browser'] = browser
    caps['resolution'] = '1600x1200'

    case browser
      when 'IE'
        caps['os'] = 'Windows'
        caps['os_version'] = '10'
        caps['browser_version'] = '11.0'
      when 'Edge'
        caps['os'] = 'Windows'
        caps['os_version'] = '10'
      else
        caps['os'] = 'OS X'
        caps['os_version'] = 'Sierra'
    end

    caps['browserstack.debug'] = true
    caps['browserstack.networkLogs'] = true

    self.driver = Selenium::WebDriver.for(
      :remote,
      url: "http://tiffanyrea1:#{@creds['browserstack_key']}@hub-cloud.browserstack.com/wd/hub",
      desired_capabilities: caps
    )
  end

  def local
    self.driver = Watir::Browser.new :"#{browser}", {timeout: 120}
  end
end
