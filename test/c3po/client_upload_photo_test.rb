# encoding: utf-8
require_relative '../test_helper'

# TS-288: C3PO Regression
# UI Test: Upload Photo (Client)
class ClientUploadPhotoTest < Common
  def setup
    super

    # This client is a premium client for thid test cases
    # If he goes stale causing test to fail, find another
    # replace email address and client id accordingly
    email = 'ncsa.automation+e6cc@gmail.com'

    C3PO.setup(@browser)
    UIActions.user_login(email, 'ncsa1333')
  end

  def teardown
    delete_photo
    super
  end

  def delete_photo
    open_photo_edit
    form.link(text: "Delete Photo").click
    Watir::Wait.until { @browser.span(class: 'close_flash').present? }
  end

  def open_photo_edit
    UIActions.goto_edit_profile
    sleep 2
    photo.hover
    photo.element(class: 'fa-camera').click
  end

  def form
    @browser.form(id: 'edit_client_photo')
  end

  def photo
    photo = @browser.element(class: 'client_photo_link')
  end

  def test_client_upload_photo
    path = File.absolute_path('test/c3po/cat.png')
    open_photo_edit

    form.element(id: 'upload').send_keys path
    sleep 1
    Watir::Wait.until(timeout: 30) { photo.present? }

    # verify photo src is now from s3.amazonaws.com
    photo_src = photo.element(tag_name: 'img').attribute('src')
    s3_url = 's3.amazonaws.com/rms-rmfiles-staging/client_photos/'
    assert (photo_src.include? s3_url), "Client photo not pulled from S3 - #{photo_src}"

    # verify upload successful message
    flash_msg = @browser.element(class: 'flash_msg').text
    expected_msg = 'Your photo was updated!'
    msg = "Success message: #{flash_msg} - Expected: #{expected_msg}"
    assert_equal expected_msg, flash_msg, msg

    # check photo shows up in profile
    @browser.element(class: 'button--primary').click
    profile_pic = @browser.element(class: 'profile-pic')
    profile_pic_src = profile_pic.element(tag_name: 'img').attribute('src')
    msg = "Profile pic src #{profile_pic_src} not matching what uploaded #{photo_src}"
    assert_equal photo_src, profile_pic_src, msg
  end
end
