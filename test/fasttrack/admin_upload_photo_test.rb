# encoding: utf-8
require_relative '../test_helper'

# TS-284: C3PO Regression
# UI Test: Upload Photo (Admin)
class AdminUploadPhotoTest < Common
  def setup
    super

    # This client is a premium client for thid test cases
    # If he goes stale causing test to fail, find another
    # replace email address and client id accordingly
    email = 'ncsa.automation+da42@gmail.com'
    client_id = '5784854'

    C3PO.setup(@browser)
    UIActions.fasttrack_login
    C3PO.impersonate(client_id)
  end

  def teardown
    delete_photo
    super
  end

  def test_admin_upload_photo
    upload_photo

    # verify upload successful message
    success_msg = flash_msg.text
    expected_msg = 'Your photo was updated!'
    msg = "Success message: #{success_msg} - Expected: #{expected_msg}"
    assert_equal expected_msg, success_msg, msg

    # verify photo src is now from s3.amazonaws.com
    photo_src = photo.element(tag_name: 'img').attribute('src')
    s3_url = 's3.amazonaws.com/rms-rmfiles-staging/client_photos/'
    assert (photo_src.include? s3_url), "Client photo not pulled from S3 - #{photo_src}"

    # check photo shows up in profile
    @browser.element(class: 'button--primary').click
    profile_pic = @browser.element(class: 'profile-pic')
    profile_pic_src = profile_pic.element(tag_name: 'img').attribute('src')
    msg = "Profile pic src #{profile_pic_src} not matching what uploaded #{photo_src}"
    assert_equal photo_src, profile_pic_src, msg
  end

  private

  def photo
    photo = @browser.element(class: 'client_photo_link')
  end

  def flash_msg
    @browser.element(class: 'flash_msg')
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

  def upload_photo
    open_photo_edit
    path = File.absolute_path('test/c3po/cat.png')
    form.element(name: "client_photo[image]").send_keys path
    sleep 5
    Watir::Wait.until { flash_msg.present? }
  end

  def delete_photo
    open_photo_edit
    form.link(text: "Delete Photo").click
    Watir::Wait.until { @browser.span(class: 'close_flash').present? }
  end
end