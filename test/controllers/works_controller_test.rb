require "test_helper"

describe WorksController do

  let (:work_hash) do
    {
      work: {
        category: "book",
        title: "Test book",
        creator: "Some author",
        publication_year: Time.new(2000),
        description: "This is the story of a girl, who cried a river and drowned the whole wooooorld...."
      }
    }
  end

  describe "index" do
    it "responds with success when accessed" do
      get works_path
      must_respond_with :success
    end
  end

  describe "new" do
    it "responds with success when accessed" do
      get new_work_path
      must_respond_with :success
    end
  end

  describe "create" do

    it "posts a valid new work and redirects to associated show page" do
      expect {
        post works_path, params: work_hash
      }.must_differ "Work.count", 1

      latest_work = Work.last

      must_redirect_to work_path(latest_work.id)

      expect(latest_work[:category]).must_equal work_hash[:work][:category]
      expect(latest_work[:title]).must_equal work_hash[:work][:title]
      expect(latest_work[:creator]).must_equal work_hash[:work][:creator]
      expect(latest_work[:publication_year].year).must_equal work_hash[:work][:publication_year].year
      expect(latest_work[:description]).must_equal work_hash[:work][:description]
    end

    it "does not post an invalid new work and responds with bad_request" do
      expect {
        post works_path, params: {work: {category: "book", title: "missing creator", publication_year: Time.now}}
      }.wont_change "Work.count"

      must_respond_with :bad_request
    end
  end

  describe "show" do
    it "responds with success when accessing a valid work" do
      work = works(:album1)
      get work_path(work.id)
      must_respond_with :success
    end

    it "responds with not_found when accessing a non-existing work" do
      get work_path(-1)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "responds with success for an existing, valid driver" do
      work = works(:book1)
      get edit_work_path(work.id)
      must_respond_with :success
    end

    it "responds with redirect when getting the edit page for a non-existing work" do
      get edit_work_path(-1)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "successful save redirects to show page when updating an existing driver with valid params" do
      work = works(:movie1)
      expect {
        patch work_path(work.id), params: work_hash
      }.wont_change "Work.count"

      must_redirect_to work_path(work.id)

      work.reload

      expect(work[:category]).must_equal work_hash[:work][:category]
      expect(work[:title]).must_equal work_hash[:work][:title]
      expect(work[:creator]).must_equal work_hash[:work][:creator]
      expect(work[:publication_year].year).must_equal work_hash[:work][:publication_year].year
      expect(work[:description]).must_equal work_hash[:work][:description]
    end

    it "responds with bad_request when attempting to update an existing driver with invalid params" do
      work = works(:book1)

      expect {
        patch work_path(work.id), params: {work: {category: "book", title: nil, creator: "book missing title", publication_year: Time.new(1993)}}
      }.wont_change "Work.count"

      must_respond_with :bad_request
    end

    it "responds with not_found when attempting to update an invalid driver with valid params" do
      expect {
        patch work_path(-1), params: work_hash
      }.wont_change "Work.count"

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "destroys an existing work then redirects" do
      work = works(:album1)

      expect {
        delete work_path(work.id)
      }.must_differ "Work.count", -1

      found_work = Work.find_by(title: work.title)

      expect(found_work).must_be_nil

      must_redirect_to works_path

    end

    it "does not change the db when the driver does not exist, then responds with " do
      expect{
        delete work_path(-1)
      }.wont_change "Work.count"

      must_respond_with :not_found
    end
  end

  #TODO: is this test written correctly?
  describe "upvote" do
    before do
      @work = works(:album1)
      @user = users(:user1)
    end

    it "get success message and redirect when a logged in user upvotes" do
      new_user = User.create(name: "new user")
      perform_login(new_user)

      post upvote_work_path(@work.id), params: {id: @work.id}

      must_respond_with :redirect
      expect(flash[:success]).wont_be_nil
      expect(flash[:error]).must_be_nil
    end

    it "error message added and get redirect if a logged in user attempts to upvote a work they already voted for" do
      perform_login(@user)

      post upvote_work_path(@work.id), params: {id: @work.id}
      post upvote_work_path(@work.id), params: {id: @work.id}

      must_respond_with :redirect
      expect(flash[:success]).must_be_nil
      expect(flash[:error]).wont_be_nil
    end

    it "error message added and get redirect when no user is logged in and upvote is attempted" do
      post upvote_work_path(@work.id), params: {id: @work.id}

      must_respond_with :redirect
      expect(flash[:success]).must_be_nil
      expect(flash[:error]).wont_be_nil
    end
  end
end
