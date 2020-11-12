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
    it "must have a category" do
      new_work.category = nil
      expect(new_work.valid?).must_equal false
    end
    it "must have a title" do
      new_work.title = nil
      expect(new_work.valid?).must_equal false
    end
    it "must have a creator" do
      new_work.creator = nil
      expect(new_work.valid?).must_equal false
    end
    it "must have a publication year" do
      new_work.publication_year = nil
      expect(new_work.valid?).must_equal false
    end
    it "validation error message gets stored for required fields" do
      new_work.category = nil
      new_work.title = nil
      new_work.creator = nil
      new_work.publication_year = nil
      new_work.description = nil
      new_work.save
      expect(new_work.errors.messages).must_include :category
      expect(new_work.errors.messages).must_include :title
      expect(new_work.errors.messages).must_include :creator
      expect(new_work.errors.messages).must_include :publication_year
    end
  end

  describe "custom methods" do
    describe "validate_category" do
      it "will raise an exception for invalid string inputs for category" do
        new_work.category = "test_fail"
        expect {
          new_work.validate_category
        }.must_raise ArgumentError
      end
      it "will raise an exception for empty string inputs for category" do
        new_work.category = ""
        expect {
          new_work.validate_category
        }.must_raise ArgumentError
      end
    end

    describe "validate_publication_year" do
      it "will raise an exception for string inputs for category" do
        new_work.publication_year = "2007"
        expect {
          new_work.validate_publication_year
        }.must_raise ArgumentError
      end
      it "will raise an exception for integer inputs for category" do
        new_work.publication_year = 2007
        expect {
          new_work.validate_publication_year
        }.must_raise ArgumentError
      end
    end

  end

end
