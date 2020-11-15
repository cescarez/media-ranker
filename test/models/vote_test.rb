require "test_helper"

#note: submit_date presence is not tested for as it gets assigned in Work#upvote
#
describe Vote do
  let (:vote) do
    votes(:vote1)
  end

  describe "instantiation" do
    it "can be instantiated" do
      expect(vote.valid?).must_equal true
    end

    it "will have the required fields" do
      [:work_id, :user_id].each do |field|
        expect(vote).must_respond_to field
      end
    end
  end

  describe "relationships" do
    let (:other_work) { works(:book1) }
    let (:other_user) { users(:user2) }

    it "has a work and user" do
      expect(vote.work).wont_be_nil
      expect(vote.work_id).wont_be_nil
      expect(vote.user).wont_be_nil
      expect(vote.user_id).wont_be_nil
    end

    it "changing the work and user changes the associated foreign keys" do
      vote.work = other_work
      vote.user = other_user

      expect(vote.work_id).must_equal other_work.id
      expect(vote.user_id).must_equal other_user.id
    end

    it "changing the work and user foreign keys changes the associated instances" do
      vote.work_id = other_work.id
      vote.user_id = other_user.id

      expect(vote.work).must_equal other_work
      expect(vote.user).must_equal other_user
    end
  end

end
