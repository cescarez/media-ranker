require "test_helper"

#note: submit_date presence is not tested for as it gets assigned in Work#upvote
#
describe Vote do
  let (:new_vote) do
    work = works(:album1)
    user = users(:user1)
    Vote.new(user: user, work: work)
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
    let (:other_work) { works(:book1) }
    let (:other_user) { users(:user2) }

    it "has a work and user" do
      new_vote.save
      expect(new_vote.work).wont_be_nil
      expect(new_vote.work_id).wont_be_nil
      expect(new_vote.user).wont_be_nil
      expect(new_vote.user_id).wont_be_nil
    end

    it "changing the work and user  changes the associated foreign keys" do
      new_vote.work = other_work
      new_vote.user = other_user

      expect(new_vote.work_id).must_equal other_work.id
      expect(new_vote.user_id).must_equal other_user.id
    end

    it "changing the work and user foreign keys changes the associated instances" do
      new_vote.work_id = other_work.id
      new_vote.user_id = other_user.id

      expect(new_vote.work).must_equal other_work
      expect(new_vote.user).must_equal other_user
    end
  end

  # describe "custom methods" do
  #
  # end

end
