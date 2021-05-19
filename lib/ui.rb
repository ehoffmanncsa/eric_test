# encoding: utf-8

class UI
  attr_accessor :driver
  attr_accessor :browser

  def initialize hub, browser = nil
    @static = Default.static_info

    self.browser = browser.nil? ? 'firefox' : browser
    case hub
      when 'docker' then docker
      when 'browserstack' then browserstack
      when 'local' then local
    end
  end

  def docker
    # default to jenkins server hostname
    # use 'http://localhost:4444/wd/hub' when run in docker locally
    # or when run docker on your machine (E.g: Mac)
    #'http://kb-jenkins01:4444/wd/hub' - jenkins server

    port = ENV['PORT'].nil? ? 4444 : ENV['PORT'].split(':')[0]

    browser_opts = { timeout: 120, url: "http://kb-jenkins01:#{port}/wd/hub" }
    self.driver = Watir::Browser.new :"#{browser}", options: browser_opts
    #Watir::Browser.new :"#{browser}", opts
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
      url: "http://tiffanyrea1:#{@static['browserstack_key']}@hub-cloud.browserstack.com/wd/hub",
      desired_capabilities: caps
    )
  end

  def local
    browser_opts = { timeout: 120 }
    self.driver = Watir::Browser.new :"#{browser}", options: browser_opts
  end
end
