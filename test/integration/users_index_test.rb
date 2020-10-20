require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)

  end
    
  test "index including pagination" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete', count: 1
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test "users not activated are not shown either appearces in the index" do
    post users_path, params: {  user: { name: "Example User",
                                        email: "user@example.com",
                                        password: "password",
                                        password_confirmation: "password" } }
    user = assigns(:user)
    assert_not user.activated?
    log_in_as(@non_admin)
    get users_path
    assert_select 'a[href=?]', user_path(user), count: 0
    # Activate user
    get edit_account_activation_path(user.activation_token, email: user.email)
    # user is shown in the index
    get users_path
    assert_select 'a[href=?]', user_path(user), count: 1
  end 

  test "no user profile is shown until account activation" do
    post users_path, params: {  user: { name: "Example User",
                                        email: "user@example.com",
                                        password: "password",
                                        password_confirmation: "password" } }
    user = assigns(:user)
    # Visit user profile redirects to root_url
    get user_path(user)
    assert_redirected_to root_url
    # Activate user 
    get edit_account_activation_path(user.activation_token, email: user.email)
    # Visit user profile works
    get user_path(user)
    assert_template 'users/show'
  end

end
