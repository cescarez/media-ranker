require "test_helper"

describe User do
  let(:user) { users(:user1) }
  let (:other_user) { users(:user2) }

  describe "instantiation" do
    it "can be instantiated" do
      expect(user.valid?).must_equal true
    end

    it "will have the required fields" do
      expect(user).must_respond_to :name
      expect(user).must_respond_to :created_at
    end
  end


  describe "relationships" do
    it "can have multiple votes" do
      expect(user.votes.count).must_equal 15 #see votes.yml
      expect(other_user.votes.count).must_equal 15 #see votes.yml
      user.votes.each do |vote|
        expect(vote).must_be_instance_of Vote
      end
    end
  end

  describe "validates" do
    it "must have a name" do
      user.name = nil
      expect(user.valid?).must_equal false
    end
    it "validation error message gets stored" do
      user.name = nil
      user.save
      expect(user.errors.messages).must_include :name
    end
  end

  # describe "custom methods" do
  #
  # end

end
