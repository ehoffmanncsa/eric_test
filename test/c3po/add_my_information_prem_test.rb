# encoding: utf-8
require_relative '../test_helper'

# C3PO Regression
# Edit a premium client information on My Information page
# Verified the edited information is displayed on this person's profile page
# Static person used in this test case:
# username: ncsa.automation+a07f@gmail.com
# recruitinginfo email address: lisabeth.muller@test.recruitinginfo.org

class V2AddMyInformationPremTest < Common
  def setup
    super

    @athlete_email = 'lisabeth.muller@test.recruitinginfo.org'
    @graduation_year = MakeRandom.grad_yr.to_s
    @filler = C3PO::MyInformationPageFiller.new(@browser)
    @profile_page = C3PO::AthleteProfilePage.new(@browser)
  end

  def teardown
    super
  end

  def test_my_information_shows_on_profile_page
    do_preps
    gather_person_expected_information
    wait_for_page_save
    goto_athlete_profile_page
    compare_my_info_data_to_profile_page_data
  end

  private

  def fill_out_information_page
    @filler.fill_out_textfields(true) # true for premium client - to ignore email textfield
    @filler.select_grad_year(@graduation_year)
    @filler.fill_out_personal_statement
    @filler.submit
  end

  def do_preps
    UIActions.user_login('ncsa.automation+a07f@gmail.com')
    UIActions.goto_my_information
    fill_out_information_page
  end

  def gather_person_expected_information
    @athlete_fullname = "#{@filler.first_name} #{@filler.last_name}"
    @athlete_grad_year = @filler.select_grad_year(@graduation_year)
    @athlete_phone = @filler.athlete_phone
    @athlete_secondary_phone = @filler.athlete_secondary_phone
    @parent1_fullname = "#{@filler.parent1_first_name} #{@filler.parent1_last_name}".upcase
    @parent1_phone = @filler.parent1_phone
    @parent1_secondary_phone = @filler.parent1_secondary_phone
    @parent1_email = @filler.parent1_email
    @parent2_fullname = "#{@filler.parent2_first_name} #{@filler.parent2_last_name}".upcase
    @parent2_phone = @filler.parent2_phone
    @parent2_secondary_phone = @filler.parent2_secondary_phone
    @parent2_email = @filler.parent2_email
    @address = @filler.address
    @zip = @filler.zip
    @city = @filler.city
    @preferred_major = @filler.preferred_major
    @personal_statement = @filler.personal_statement
  end

  def goto_athlete_profile_page
    @browser.element(class: 'button--primary').click
  end

  def wait_for_page_save
    Watir::Wait.until(timeout: 90) { @browser.div(class: ["success", "flash", "flash_msg"]).present? }
  end

  # do comparision
  def compare_my_info_data_to_profile_page_data
    failure = []
    failure << 'Incorrect athlete name' unless @athlete_fullname == @profile_page.athlete_fullname
    failure << 'Incorrect grad year' unless @athlete_grad_year == @profile_page.athlete_grad_year
    failure << 'Incorrect athlete top email' unless @athlete_email == @profile_page.athlete_top_email
    failure << "Incorrect athlete bottom email" unless @athlete_email == @profile_page.athlete_bottom_email
    failure << 'Incorrect athlete top phone' unless @athlete_phone == @profile_page.athlete_top_phone
    failure << 'Incorrect athlete bottom phone' unless @athlete_phone == @profile_page.athlete_bottom_phone
    failure << 'Incorrect athlete secondary phone' unless @athlete_secondary_phone == @profile_page.athlete_secondary_phone

    failure << 'Incorrect parent1 name' unless @parent1_fullname == @profile_page.parent1_fullname
    failure << 'Incorrect parent1 email' unless @parent1_email == @profile_page.parent1_email
    failure << 'Incorrect parent1 phone' unless @parent1_phone == @profile_page.parent1_phone
    failure << 'Incorrect parent1 secondary phone' unless @parent1_secondary_phone == @profile_page.parent1_secondary_phone

    failure << 'Incorrect parent2 name' unless @parent2_fullname == @profile_page.parent2_fullname
    failure << 'Incorrect parent2 email' unless @parent2_email == @profile_page.parent2_email
    failure << 'Incorrect parent2 phone' unless @parent2_phone == @profile_page.parent2_phone
    failure << 'Incorrect parent2 secondary phone' unless @parent2_secondary_phone == @profile_page.parent2_secondary_phone
    failure << 'Incorrect address' unless @address == @profile_page.athlete_address
    failure << 'Incorrect city' unless @city == @profile_page.athlete_bottom_city
    failure << 'Incorrect zip' unless @zip == @profile_page.athlete_zipcode
    #failure << 'Incorrect major' unless @preferred_major == @profile_page.athlete_major
    # --this comes from preferences page
    failure << 'Incorrect personal statement' unless @personal_statement == @profile_page.personal_statement
    assert_empty failure
  end
end
