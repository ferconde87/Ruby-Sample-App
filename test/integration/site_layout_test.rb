require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path, count: 1
    assert_select "a[href=?]", signup_path, count: 1
    assert_select "a[href=?]", about_path, count: 1
    assert_select "a[href=?]", contact_path, count: 1
    assert_select "a[href=?]", users_path, count: 0
    get contact_path
    assert_select "title", full_title("Contact")
    get signup_path
    assert_select "title", full_title("Sign up")
    get about_path
    assert_select "title", full_title("About")
    get help_path
    assert_select "title", full_title("Help")
    log_in_as(@user)
    assert is_logged_in?
    assert_redirected_to @user
    get root_path #I need to do a get to refresh the html, in other to see the links as a loggin user 
    assert_select "a[href=?]", users_path, count: 1
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user), count: 1
    assert_select "a[href=?]", logout_path, count: 1
    #assert_select "a[href=?]", signup_path, count: 0 #this link should disappear after login
  end
end