# encoding: utf-8

# Set up a new lead for POS base 2 conditions: grad year and package type
# choosing and returning 6 payments financing option as default
# that way we can test for remaining balance and first payment made
module MSSetup
  def self.setup(ui_object)
    @browser = ui_object
  end

  def self.modal_present?
    begin
      # in some cases there will be a popup modal for athlete to accept
      Watir::Wait.until { @browser.element(:class, 'mfp-content').visible? }
      return true
    rescue
      return false
    end
  end

  def self.click_yes
    popup = @browser.element(:class, 'mfp-content')
    popup.element(:class, 'button--secondary').click
    sleep 1
  end

  def self.set_password
    privacy_modal_button = @browser.element(class: 'privacy-policy-modal__cta-button')
    privacy_modal_button.click if privacy_modal_button.exists?

    click_yes if modal_present?

    @browser.text_field(id: 'user_account_password').set 'ncsa1333'
    @browser.text_field(id: 'user_account_password_confirmation').set 'ncsa1333'
    @browser.button(name: 'commit').click
    sleep 3

    Watir::Wait.until(timeout: 90) { @browser.div(class: 'OnboardingWrapper-cHmkDT').present? }
    sleep 3
  end

  def self.find_swoosh
    begin
      Watir::Wait.until { @browser.element(:class, 'fa-angle-down').visible? }
    rescue
      @browser.refresh
      retry
    end

    @browser.element(:class, 'fa-angle-down').click

    dropdown = @browser.element(:class, 'jq-dropdown-panel')
    swoosh = dropdown.element(:class, 'fa-swoosh')
    swoosh.enabled? ? (return swoosh) : (raise '[ERROR] Cannot find swoosh in profile menu')
  end

  def self.make_commitment
    # select all checkboxes
    # I can't seem to find any better option than xpath for the checkbox yet
    ['profile', 'website', 'communication', 'supporting', 'process'].each do |commit|
      div = @browser.div(:id, commit)
      div.click
      div.element(:xpath, "//*[@id=\"#{commit}\"]/div[2]/div/div[2]/div/i").click
    end

    # then get activated
    get_activate = @browser.div(:class, 'button--next')
    raise '[ERROR] Cannot find activate button' unless get_activate.enabled?

    get_activate.click
    sleep 1
  end

  def self.goto_offerings
    clientrms = Default.env_config['clientrms']
    @browser.goto(clientrms['base_url'] + clientrms['offerings_page'])

    if (@browser.url.include? 'commitment')
      make_commitment
    end

    sleep 1
  end

  def self.open_payment_plan
    payment_plan = @browser.link(:text, 'Choose Payment Plan')
    payment_plan.click; sleep 0.5
    payment_plan.scroll.to :center
    sleep 1
  end
end
