require "test_helper"

describe WorksController do
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

    it "posts a valid new work and redirects to associated show page" do
      expect {
        post works_path, params: work_hash
      }.must_differ "Work.count", 1

      p Work.count

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
        post works_path, params: {work: {category: "book", title: "bad date", creator: "some schmuck", publication_year: nil}}
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

  end

  describe "update" do

  end

  describe "destroy" do

  end
end
