# encoding: utf-8
require_relative '../test_helper'

# TS-288: C3PO Regression
# UI Test: Upload Photo (Client)
class ClientUploadPhotoTest < Common
  def setup
    super

    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]

    POSSetup.setup(@browser)
    POSSetup.buy_package(@email, 'elite')
  end

  def teardown
    super
  end

  def photo
    photo = @browser.element(:class, 'client_photo_link')
  end

  def test_client_upload_photo
    path = File.absolute_path('test/c3po/cat.png')
    UIActions.user_login(@email)
    UIActions.goto_edit_profile

    photo.hover
    photo.element(:class, 'fa-camera').click

    form = @browser.element(:id, 'edit_client_photo')
    form.element(:id, 'client_photo_image').send_keys path
    form.element(:name, 'commit').click

    # verify photo src is now from s3.amazonaws.com
    photo_src = photo.element(:tag_name, 'img').attribute('src')
    s3_url = 'http://s3.amazonaws.com/rms-rmfiles-staging/client_photos/'
    assert (photo_src.include? s3_url), "Client photo not pulled from S3 - #{photo_src}"

    # verify upload successful message
    flash_msg = @browser.element(:class, 'flash_msg').text
    expected_msg = 'Your photo was updated!'
    msg = "Success message: #{flash_msg} - Expected: #{expected_msg}"
    assert_equal expected_msg, flash_msg, msg

    # check photo shows up in profile
    @browser.element(:class, 'button--primary').click
    profile_pic = @browser.element(:class, 'profile-pic')
    profile_pic_src = profile_pic.element(:tag_name, 'img').attribute('src')
    msg = "Profile pic src #{profile_pic_src} not matching what uploaded #{photo_src}"
    assert_equal photo_src, profile_pic_src, msg
  end
end
