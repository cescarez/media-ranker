require "test_helper"

describe Vote do
  let (:new_vote) do
    new_work = Work.create!(
      category: "book",
      title: "Test book",
      creator: "Some author",
      publication_year: Time.new(2000),
      description: "This is the story of a girl, who cried a river and drowned the whole wooooorld...."
    )
    new_user = User.create!(name: "Test User")
    Vote.new(user: new_user, work: new_work)
  end

  describe "instantiation" do
    it "can be instantiated" do
      expect(new_vote.valid?).must_equal true
    end

    it "will have the required fields" do
      new_vote.save
      vote = Vote.last
      [:work_id, :user_id].each do |field|
        expect(vote).must_respond_to field
      end
    end
  end

  describe "relationships" do
    let (:other_work) do
      Work.create!(
      category: "book",
      title: "Some other book",
      creator: "Some author",
      publication_year: Time.new(2000),
      description: "This is the story of a girl, who cried a river and drowned the whole wooooorld...."
      )
    end

    let (:other_user) do
      User.create!(name: "Other User")
    end

    it "has a work and user" do
      new_vote.save
      expect(new_vote.work).wont_be_nil
      expect(new_vote.work_id).wont_be_nil
      expect(new_vote.user).wont_be_nil
      expect(new_vote.user_id).wont_be_nil
    end

    it "changing the work and user  changes the associated foreign keys" do
      other_work
      other_user

      new_vote.work = other_work
      new_vote.user = other_user

      expect(new_vote.work_id).must_equal other_work.id
      expect(new_vote.user_id).must_equal other_user.id
    end

    it "changing the work and user foreign keys changes the associated instances" do
      other_work
      other_user

      new_vote.work_id = other_work.id
      new_vote.user_id = other_user.id

      expect(new_vote.work).must_equal other_work
      expect(new_vote.user).must_equal other_user
    end
  end


  describe "custom methods" do

  end

end
