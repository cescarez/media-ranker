require "test_helper"

describe Work do
  let (:new_work) do
    Work.new(
      category: "book",
      title: "Test book",
      creator: "Some author",
      publication_year: Time.new(2000),
      description: "This is the story of a girl, who cried a river and drowned the whole wooooorld...."
    )
  end

  describe "instantiation" do
    it "can be instantiated" do
      expect(new_work.valid?).must_equal true
    end

    it "will have the required fields" do
      work = works(:album1)
      [:category, :title, :creator, :publication_year, :description].each do |field|
        expect(work).must_respond_to field
      end
    end
  end

  describe "relationships" do
    it "can have multiple votes" do
      other_work = Work.create!(category: "book", title: "Some Title", creator: "some schmuck", publication_year: Time.now)
      new_work.save

      new_user1 = User.create!(name: "Test User 1")
      new_user2 = User.create!(name: "Test User 2")
      vote1 = Vote.create!(work: new_work, user: new_user1)
      vote2 = Vote.create!(work: new_work, user: new_user2)
      vote3 = Vote.create!(work: other_work, user: new_user1)

      expect(new_work.votes.count).must_equal 2
      new_work.votes.each do |vote|
        expect(vote).must_be_instance_of Vote
      end
    end
  end

  describe "validates" do

  end

  describe "custom methods" do

  end

end
