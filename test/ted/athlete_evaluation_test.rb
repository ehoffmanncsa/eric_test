# encoding: utf-8
require_relative '../test_helper'

# TED Regression
# UI Test: Coach Admin Evaluates Athlete (PA cannot)

=begin
  Coach Admin org Awesome Sauce:
    - Find a random Accepted athlete and get his id
    - Go to an athlete's showpage using athlete's id
    - Go to Athlete Evaluation tab
    - Choose star rating 2 (other options are not selectable to watir)
    - Make sure athlete's rating also get updated to 2
    - Reset rating to 1 star

  PA impersonate org Awesome Sauce:
    - Find a random Accepted athlete and get his id
    - Go to an athlete's showpage using athlete's id
    - Go to Athlete Evaluation tab
    - Choose star rating 2
    - Make sure error alert is seen
=end

class AthleteEvaluationTest < Common
  def setup
    super
    TED.setup(@browser)
    @athlete_id = get_accepted_athlete_id
  end

  def teardown
    super
  end

  def get_accepted_athlete_id
    TEDAthleteApi.setup
    accepted_athletes = TEDAthleteApi.find_athletes_by_status('accepted')
    accepted_athletes.sample['id']
  end

  def goto_athlete_evaluation
    @browser.goto "https://team-staging.ncsasports.org/athletes/#{@athlete_id}"
    @browser.link(:text, 'Athlete Evaluation').click
  end

  def reset_rating
    rating_area = @browser.element(:class, 'star-rating').element(:class, 'rating')
    rating_area.element(:for, 'star1').click
    Watir::Wait.until { TED.modal.present? }
    TED.modal.button(:text, 'Confirm').click; sleep 1
  end

  def select_2star_rating
    rating_area = @browser.element(:class, 'star-rating').element(:class, 'rating')
    rating_area.element(:for, 'star2').click
    Watir::Wait.until { TED.modal.present? }
    TED.modal.button(:text, 'Confirm').click; sleep 3
  end

  def check_2star_rating
    stars = []; failure = []
    stat_area = @browser.element(:class, 'stats').element(:class, 'rating')
    ratings = stat_area.elements(:class, 'fa')
    ratings.each { |r| stars << r.attribute_value('class') }

    failure << 'First start not highlighted' unless stars[0].eql? 'fa fa-star fa-undefined'
    failure << 'Second start not highlighted' unless stars[1].eql? 'fa fa-star fa-undefined'
    assert_empty failure
  end

  def check_rating_fail
    alert = @browser.element(:class, 'star-rating').element(:class, 'alert')
    assert alert.present?, 'No alert found'

    expect_msg = 'Failed to update athlete rating. Please try again later.'
    assert_equal expect_msg, alert.text, 'Incorrect alert message'
  end

  def test_coach_admin_evaluates_athlete
    UIActions.ted_login
    goto_athlete_evaluation
    select_2star_rating
    check_2star_rating
    reset_rating
  end

  def test_PA_cannot_evaluate_athlete
    TED.impersonate_org
    goto_athlete_evaluation
    select_2star_rating
    check_rating_fail
  end
end
