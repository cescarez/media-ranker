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

  describe "new" do
    it "responds with success when accessed" do
      get new_user_path
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

  describe "edit" do
    it "responds with success for an existing, valid driver" do
      user = users(:user1)
      get edit_user_path(user.id)
      must_respond_with :success
    end

    it "responds with redirect when getting the edit page for a non-existing user" do
      get edit_user_path(-1)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "successful save redirects to show page when updating an existing driver with valid params" do
      user = users(:user1)
      expect {
        patch user_path(user.id), params: user_hash
      }.wont_change "User.count"

      must_redirect_to user_path(user.id)

      user.reload

      expect(user[:name]).must_equal user_hash[:user][:name]
    end

    it "responds with bad_request when attempting to update an existing driver with invalid params" do
      user = users(:user1)

      expect {
        patch user_path(user.id), params: {user: {name: nil}}
      }.wont_change "User.count"

      must_respond_with :bad_request
    end

    it "responds with not_found when attempting to update an invalid driver with valid params" do
      expect {
        patch user_path(-1), params: user_hash
      }.wont_change "User.count"

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "destroys an existing user then redirects" do
      user = users(:user1)

      expect {
        delete user_path(user.id)
      }.must_differ "User.count", -1

      found_user = User.find_by(name: user.name)

      expect(found_user).must_be_nil

      must_redirect_to users_path

    end

    it "does not change the db when the driver does not exist, then responds with " do
      expect{
        delete user_path(-1)
      }.wont_change "User.count"

      must_respond_with :not_found
    end
  end
end
