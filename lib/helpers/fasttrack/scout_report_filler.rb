# frozen_string_literal: true

# require 'pry'
module ScoutReport
  def self.setup(browser)
    @browser = browser
  end

  def self.enter_video_comments
    @browser.elements(class: %w[string required video-notes])[0].send_keys 'Coach Eric Video comments'
    @browser.elements(class: %w[string required video-notes])[1].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required video-notes])[2].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required video-notes])[3].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required video-notes])[4].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required video-notes])[5].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required video-notes])[6].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required video-notes])[7].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required video-notes])[8].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required video-notes])[9].send_keys MakeRandom.lorem
    sleep 1
  end

  def self.enter_key_skills_comments
    @browser.textarea(name: 'reason[0]').send_keys MakeRandom.lorem
    @browser.textarea(name: 'reason[1]').send_keys MakeRandom.lorem
    @browser.textarea(name: 'reason[2]').send_keys 'Coach Eric Key Skills comments'
    @browser.textarea(name: 'reason[3]').send_keys MakeRandom.lorem
    @browser.textarea(name: 'reason[4]').send_keys MakeRandom.lorem
    @browser.textarea(name: 'reason[5]').send_keys MakeRandom.lorem
    @browser.textarea(name: 'reason[6]').send_keys MakeRandom.lorem
    @browser.textarea(name: 'reason[7]').send_keys MakeRandom.lorem
    sleep 1
  end

  def self.enter_communications_comments
    @browser.elements(class: %w[string required])[47].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required])[49].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required])[51].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required])[53].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required])[55].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required])[57].send_keys 'Coach Eric Communication Timeline comments'
    @browser.elements(class: %w[string required])[59].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required])[61].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required])[63].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required])[65].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required])[67].send_keys MakeRandom.lorem
    @browser.elements(class: %w[string required])[69].send_keys MakeRandom.lorem
  end

  def self.select_dropdowns
    # this will select values from key skill ratings, position and college pick dropdowns
    list = @browser.elements(class: %w[chosen-container chosen-container-single])
    list.each do |list|
      list.click
      list.elements(tag_name: 'li').to_a.sample.click
    end
  end

  def self.enter_email_subject
    @browser.element(id: 'scouting_report_email_template_subject').send_keys MakeRandom.lorem
  end

  def self.enter_email_body
    @browser.element(class: %w[fr-element fr-view]).send_keys MakeRandom.lorem
  end

  def self.select_coach_pick_college
    # this is not used, select_dropdowns method is used to select all dropdowns
    @target_school_ids.each do |target_school_id|
      list = @browser.element(id: "scouting_report_target_school_#{target_school_id}_college_id__chosen")
      list.click
      list.elements(tag_name: 'li').to_a.sample.click
    end
  end

  def self.save_video_comments
    @browser.element(class: %w[button--secondary admin-save-js video-clips-js]).click
  end

  def self.save_key_skills_comments
    @browser.element(id: 'save_key_skills').click
  end

  def self.save_coach_picks
    @browser.element(class: %w[button--secondary admin-save-js target-schools-js]).click
  end

  def self.save_marketing_plans
    @browser.element(class: %w[button--secondary admin-save-js marketing-plan-js]).click
  end

  def self.save_communication_timeline
    @browser.element(class: %w[button--secondary admin-save-js communication-timeline-js]).click
  end

  def self.save_email_template
    @browser.element(class: %w[button--secondary admin-save-js email-template-js]).click
  end

  def self.publish_report
    @browser.element(class: %w[publish-js button--primary]).click
  end

  def self.preview_report
    @browser.element(class: %w[button--gray]).click
  end
end
