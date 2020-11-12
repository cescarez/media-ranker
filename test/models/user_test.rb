require "test_helper"

describe User do
  let(:new_user) do
    User.new(name: "Test User")
  end

  describe "instantiation" do
    it "can be instantiated" do
      expect(new_user.valid?).must_equal true
    end

    it "will have the required fields" do
      user = users(:user1)
      expect(user).must_respond_to :name
    end
  end

  describe "relationships" do
    it "can have multiple votes" do
      other_user = User.create!(name: "Other Test User")

      new_user.save

      new_work1 = Work.create!(category: "book", title: "Test book", creator: "some schmuck", publication_year: Time.now)
      new_work2 = Work.create!(category: "album", title: "Test album", creator: "some schmuck", publication_year: Time.now)
      new_work3 = Work.create!(category: "movie", title: "Test movie", creator: "some schmuck", publication_year: Time.now)
      vote1 = Vote.create!(work: new_work1, user: new_user)
      vote2 = Vote.create!(work: new_work2, user: new_user)
      vote3 = Vote.create!(work: new_work3, user: new_user)
      vote4 = Vote.create!(work: new_work3, user: other_user)

      expect(new_user.votes.count).must_equal 3
      new_user.votes.each do |vote|
        expect(vote).must_be_instance_of Vote
      end
    end
  end

  describe "validates" do
    it "must have a name" do
      new_user.name = nil
      expect(new_user.valid?).must_equal false
    end
    it "validation error message gets stored" do
      new_user.name = nil
      new_user.save
      expect(new_user.errors.messages).must_include :name
    end
  end

  describe "custom methods" do

  end


end
