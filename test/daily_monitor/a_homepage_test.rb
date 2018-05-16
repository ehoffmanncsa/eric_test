# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-118
# UI Test: Daily Monitor - Homepage
class HomePageTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  def check_desktop_login_menu
    login_button = @browser.element(class: 'menu-item-has-children')
    assert login_button.enabled?, 'Login button not found'

    login_button.hover

    failure = []

    ['Athlete Profile Login', 'College Coach Login', 'HS/Club Coach Login'].each do |link_text|
      link = @browser.link(:text, link_text)

      unless link.enabled?
        failure << "#{link_text} option not clickable"
        next
      end

      # this is failing the test because
      # https://team.ncsasports.org/sign_in gives 404
      # skip this until it changes to https://team.ncsasports.org
      next if link.text == 'HS/Club Coach Login'

      resp = DailyMonitor.get_url_response(link.attribute_value('href'))

      if resp.is_a? Integer
        failure << "#{resp} - #{option.text}" unless resp.eql? 200
      else
        failure << resp
      end
    end

    assert_empty failure
  end

  def check_desktop_start_here_buttons
    group = @browser.div(:class, 'group-hero-text')

    failure = []

    %w(Parents Athletes Coaches).each do |type|
      link_text = type + ' Start Here'
      failure << "#{link_text} option not clickable" unless group.link(:text, link_text).enabled?
    end

    assert_empty failure
  end

  def check_stand_alone_options(options)
    failure = []

    options.each do |option|
      unless option.enabled?
        failure << "#{option.text} not clickable"
        next
      end

      # this is failing the test because
      # https://team.ncsasports.org/sign_in gives 404
      # skip this until it changes to https://team.ncsasports.org
      next if option.text == 'HS/Club Coach'

      resp = DailyMonitor.get_url_response(option.attribute_value('href'))

      if resp.is_a? Integer
        failure << "#{resp} - #{option.text}" unless resp.eql? 200
      else
        failure << resp
      end
    end

    assert_empty failure
  end

  def check_options_with_subs(options)
    failure = []

    options.each do |option|
      option.click
      parent = option.parent

      unless parent.element(:class, 'menu').present?
        failure << "#{option.text} doesn't have sub menu"
        next
      end

      leaves = parent.element(:class, 'menu').elements(:class, 'leaf')

      leaves.each do |leaf|
        unless leaf.enabled?
          failure << "#{leaf.text} not clickable"
          next
        end

        resp = DailyMonitor.get_url_response(leaf.element(:tag_name, 'a').attribute_value('href'))

        if resp.is_a? Integer
          failure << "#{resp} - #{leaf.text}" unless resp.eql? 200
        else
          failure << resp
        end
      end

      option.click # close
    end

    assert_empty failure
  end

  def check_hamburger_menu
    # Using Ipad viewport size
    size = @viewports[0]
    @browser.window.resize_to(DailyMonitor.width(size), DailyMonitor.height(size))

    DailyMonitor.hamburger_menu.click # open
    menu = @browser.div(:id, 'block-menu-menu-single-page-menu-interior')
    assert menu.present?, 'Hamburger menu not open'

    stand_alone_options = []

    [
      'Athlete Log In',
      'Coach Log In',
      'HS/Club Coach',
      'Pick Your Sport',
      'Blog',
      'Parents Start Here',
      'Athletes Start Here'
    ].each { |link_text| stand_alone_options << menu.link(:text, link_text) }

    options_with_subs = []

    [
      'Recruiting Guides',
      'Our Results',
      'About NCSA'
    ].each { |link_text| options_with_subs << menu.link(:text, link_text) }

    check_stand_alone_options(stand_alone_options)
    check_options_with_subs(options_with_subs)
  end

  def test_homepage
    title = Default.static_info['pages']['home_page']['title']

    DailyMonitor.goto_page('home_page')
    assert_equal title, @browser.title, 'Incorrect page title'

    check_desktop_login_menu
    check_desktop_start_here_buttons
    check_hamburger_menu
  end

  def test_homepage_visual
    DailyMonitor.goto_page('home_page')
    DailyMonitor.subfooter.scroll.to; sleep 0.5

    failure = []

    @viewports.each do |size|
      # Open eyes and go to page
      open_eyes("TS-118 Test HomePage - #{size.keys[0]}", size)

      # check footer
      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      # Snapshot Homepage with applitool
      @eyes.screenshot "#{size.keys[0]} view"

      # Snapshot homepage with hamburger open
      unless size.keys.to_s =~ /desktop/
        DailyMonitor.hamburger_menu.click # open
        @eyes.screenshot "#{size.keys[0]} view with hamburger menu open"
        DailyMonitor.hamburger_menu.click # close
      end

      # prevent eyes from closing before done looping
      result = @eyes.action.close(false)
      msg = "Homepage #{size.keys[0]} view - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end
end
