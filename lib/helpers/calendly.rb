# frozen_string_literal: true

require_relative '../../test/test_helper'

# Calendly meeting scheduler
module Calendly
  def self.setup(browser)
    @browser = browser
    @config = Default.env_config
    MSSetup.setup(@browser)

    enroll_yr = 'junior'
    @clientrms = Default.env_config['clientrms']

    post, post_body = RecruitAPI.new(enroll_yr).ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    @athlete_first_name = post_body[:recruit][:athlete_first_name]
    @athlete_last_name = post_body[:recruit][:athlete_last_name]
    @client_id = post['client_id']

    UIActions.user_login(@recruit_email)
    MSSetup.set_password
    [@recruit_email, @athlete_first_name, @athlete_last_name, @client_id]
  end

  def self.select_schedule
    @browser.element('data-test-id': 'recruiting-assessment-button').click
    sleep 2
  end

  def self.select_parent
    @browser.element(text: "I'm a Parent").click
    sleep 1
  end

  def self.fill_out_calendly_form
    calendly_form = @browser.iframe(class: 'ncsa-iframe')
    calendly_form.iframe.elements(class: 'U5hxE___day-Button__bookable').first.click
    # select day
    calendly_form.iframe.elements('data-container': 'time-button').first.click
    sleep 2
    calendly_form.iframe.element('data-container': 'confirm-button').click
    sleep 1 # select time
    calendly_form.iframe.element(type: 'text').send_keys "#{@athlete_first_name} #{@athlete_last_name}"
    sleep 1 # enter name
    calendly_form.iframe.element(type: 'email').to_subtype.clear
    calendly_form.iframe.element(type: 'email').send_keys @recruit_email
    sleep 1 # enter email
    calendly_form.iframe.element(type: 'tel').to_subtype.clear
    calendly_form.iframe.element(type: 'tel').send_keys '3124567890'
    sleep 1 # enter phone
    calendly_form.iframe.elements(class: '_2ORJu___styles-Body__cls1').first.click
    sleep 1 # select device
    calendly_form.iframe.elements(class: '_22WAz___styles-Body__cls1')[4].click
    sleep 1 # select gpa
    calendly_form.iframe.elements(class: '_2ORJu___styles-Body__cls1')[7].click
    sleep 1 # select experience
    calendly_form.iframe.elements(class: '_2ORJu___styles-Body__cls1')[13].click
    sleep 1 # select help
    calendly_form.iframe.elements(class: '_22WAz___styles-Body__cls1')[8].click
    sleep 1 # select been recruited
  end

  def self.schedule_event
    schedule = @browser.iframe(class: 'ncsa-iframe')
    schedule.iframe.elements(class: 'MOKW6___Button__cls1').last.click
    sleep 8
  end

  def self.schedule_close
    close = @browser.element(class: 'ncsa-modal-content')
    close.element(class: 'ncsa-close').click
    sleep 5
  end
end
