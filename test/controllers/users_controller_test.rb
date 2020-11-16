require "test_helper"

describe UsersController do
  let (:user_hash) do
    {user: {name: "Test book"}}
  end

  describe "index" do
    it "responds with success when accessed" do
      get users_path
      must_respond_with :success
    end
  end

  describe "create" do

    it "posts a valid new user and redirects to associated show page" do
      expect {
        post users_path, params: user_hash
      }.must_differ "User.count", 1

      latest_user = User.last

      must_redirect_to user_path(latest_user.id)

      expect(latest_user[:name]).must_equal user_hash[:user][:name]
    end

    it "does not post an invalid new user and responds with bad_request" do
      expect {
        post users_path, params: {user: {name: nil}}
      }.wont_change "User.count"

      must_respond_with :bad_request
    end
  end

  describe "show" do
    it "responds with success when accessing a valid user" do
      user = users(:user1)
      get user_path(user.id)
      must_respond_with :success
    end

    it "responds with not_found when accessing a non-existing user" do
      get user_path(-1)
      must_respond_with :not_found
    end
  end

  # ##### user#destroy not implemented
  # describe "destroy" do
  #   it "destroys an existing user then redirects" do
  #     user = users(:user1)
  #
  #     expect {
  #       delete user_path(user.id)
  #     }.must_differ "User.count", -1
  #
  #     found_user = User.find_by(name: user.name)
  #
  #     expect(found_user).must_be_nil
  #
  #     must_redirect_to users_path
  #
  #   end
  #
  #   it "does not change the db when the driver does not exist, then responds with " do
  #     expect{
  #       delete user_path(-1)
  #     }.wont_change "User.count"
  #
  #     must_respond_with :not_found
  #   end
  # end

  describe "login form" do
    it "responds with success when accessed" do
      get login_path
      must_respond_with :success
    end
  end

  describe "login" do
    it "can log in a new user" do
      login_data = {
        user: {
          name: "New User",
        },
      }

      expect{
        post login_path, params: login_data
      }.must_differ "User.count", 1

      must_respond_with :redirect
    end

    it "can log in an existing user" do
      existing_user = users(:user1)

      expect{
        perform_login(existing_user)
      }.wont_change "User.count"

      #the user.id == session[:id] expectation happens in test_helper

      must_respond_with :redirect
    end

  end

  describe "logout" do
    it "can log out of an existing user" do
      #login in the first user in my DB (as determined by method in test_help.rb) so session[:user_id] exists

      perform_login
      expect(session[:user_id]).wont_be_nil

      expect{
        post logout_path
      }.wont_change "User.count"

      expect(session[:user_id]).must_be_nil
      expect(flash[:success]).wont_be_nil
      expect(flash[:error]).must_be_nil

      must_respond_with :redirect
      must_redirect_to root_path
    end
    it "will flash an error and redirect if no user is currently logged in" do

      post logout_path

      expect(flash[:success]).must_be_nil
      expect(flash[:error]).wont_be_nil

      must_respond_with :redirect
      must_redirect_to login_path
    end
  end

  describe "current" do
    it "returns 200 OK for a logged-in user" do
      perform_login

      expect(session[:user_id]).wont_be_nil

      expect {
        get current_user_path
      }.wont_change "session[:user_id]"


      must_respond_with :success
    end
  end
end
