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

  pp Work.all.map { |work| work.publication_year }

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
      it "will raise an exception for future publication dates" do
        new_work.publication_year = Time.now + 1.year
        expect {
          new_work.validate_publication_year
        }.must_raise ArgumentError
      end
    end

    describe "spotlight" do
      let (:other_work) do
        Work.create!(category: "album", title: "Other Title", creator: "other schmuck", publication_year: Time.now)
      end

      let (:another_work) do
         Work.create!(category: "movie", title: "Another Title", creator: "another schmuck", publication_year: Time.now)
      end

      it "will select the work with the most votes" do
        new_work.save

        new_user1 = User.create!(name: "Test User 1")
        new_user2 = User.create!(name: "Test User 2")
        vote1 = Vote.create!(work: new_work, user: new_user1)
        vote2 = Vote.create!(work: other_work, user: new_user2)
        vote3 = Vote.create!(work: other_work, user: new_user1)
        vote4 = Vote.create!(work: another_work, user: new_user1)

        top_work = Work.spotlight

        expect(top_work.id).must_equal other_work.id
      end

      it "in cases of ties, will select the work with the work with the most recent vote" do
        new_work.save

        new_user1 = User.create!(name: "Test User 1")
        new_user2 = User.create!(name: "Test User 2")
        vote1 = Vote.create!(work: other_work, user: new_user1)
        vote2 = Vote.create!(work: new_work, user: new_user2)
        vote3 = Vote.create!(work: another_work, user: new_user1)
        vote4 = Vote.create!(work: other_work, user: new_user1)
        vote5 = Vote.create!(work: another_work, user: new_user1)
        vote6 = Vote.create!(work: new_work, user: new_user2)

        top_work = Work.spotlight

        expect(top_work.id).must_equal new_work.id
      end
    end

    describe "top_ten" do



      describe "albums" do
        before do
          @winning_work = {
            category: "album",
            creator: "Winner",
            publication_year: Time.now
          }

          @losing_work = {
            category: "album",
            creator: "Loser",
            publication_year: Time.now
          }

          @losing_works = []
          @winning_works = []
        end

        it "selects top ten albums based on votes" do
          new_user = User.create!(name: "Test User")

          12.times do |count|
            @losing_work[:title] = "Losing album #{count}"
            @winning_work[:title] = "Winning album #{count}"
            @losing_works << Work.create(@losing_work)
            @winning_works << Work.create(@winning_work)
          end

          @losing_works.each do |work|
            Vote.create!(work: work, user: new_user)
          end

          @winning_works.each do |work|
            Vote.create!(work: work, user: new_user)
            Vote.create!(work: work, user: new_user)
          end

          top_ten = Work.top_ten("album")

          expect(top_ten.length).must_equal 10

          top_ten.each do |work|
            expect(@winning_works).must_include work
          end
        end

        it "selects all albums if there are less than ten in db" do
          new_user = User.create!(name: "Test User")
          db_works = Work.all.filter { |work| work.category == "album" }
          num_new_works = 5

          num_new_works.times do |count|
            @winning_work[:title] = "Winning album #{count}"
            @winning_works << Work.create(@winning_work)
          end

          @winning_works.each do |work|
            Vote.create!(work: work, user: new_user)
          end

          top_ten = Work.top_ten("album")

          expect(top_ten.length).must_equal num_new_works + db_works.length

          top_ten.each do |work|
            expect(@winning_works += db_works).must_include work
          end
        end

        it "returns an empty list when the db is empty" do
          Work.delete_all
          top_ten = Work.top_ten("album")
          expect(top_ten.length).must_equal 0
          expect(top_ten).must_be_empty
        end
      end

      #####################
      describe "books" do

        before do
          @winning_work = {
            category: "book",
            creator: "Winner",
            publication_year: Time.now
          }

          @losing_work = {
            category: "book",
            creator: "Loser",
            publication_year: Time.now
          }

          @losing_works = []
          @winning_works = []
        end

        it "selects top ten books based on votes" do
          new_user = User.create!(name: "Test User")

          12.times do |count|
            @losing_work[:title] = "Losing book #{count}"
            @winning_work[:title] = "Winning book #{count}"
            @losing_works << Work.create(@losing_work)
            @winning_works << Work.create(@winning_work)
          end

          @losing_works.each do |work|
            Vote.create!(work: work, user: new_user)
          end

          @winning_works.each do |work|
            Vote.create!(work: work, user: new_user)
            Vote.create!(work: work, user: new_user)
          end

          top_ten = Work.top_ten("book")

          expect(top_ten.length).must_equal 10

          top_ten.each do |work|
            expect(@winning_works).must_include work
          end
        end

        it "selects all books if there are less than ten in db" do
          new_user = User.create!(name: "Test User")
          db_works = Work.all.filter { |work| work.category == "book" }
          num_new_works = 5

          num_new_works.times do |count|
            @winning_work[:title] = "Winning book #{count}"
            @winning_works << Work.create(@winning_work)
          end

          @winning_works.each do |work|
            Vote.create!(work: work, user: new_user)
          end

          top_ten = Work.top_ten("book")

          expect(top_ten.length).must_equal num_new_works + db_works.length

          top_ten.each do |work|
            expect(@winning_works += db_works).must_include work
          end
        end

        it "returns an empty list when the db is empty" do
          Work.delete_all
          top_ten = Work.top_ten("book")
          expect(top_ten.length).must_equal 0
          expect(top_ten).must_be_empty
        end
      end

      #####################
      describe "movies" do

        before do
          @winning_work = {
            category: "movie",
            creator: "Winner",
            publication_year: Time.now
          }

          @losing_work = {
            category: "movie",
            creator: "Loser",
            publication_year: Time.now
          }

          @losing_works = []
          @winning_works = []
        end

        it "selects top ten movies based on votes" do
          new_user = User.create!(name: "Test User")

          12.times do |count|
            @losing_work[:title] = "Losing movie #{count}"
            @winning_work[:title] = "Winning movie #{count}"
            @losing_works << Work.create(@losing_work)
            @winning_works << Work.create(@winning_work)
          end

          @losing_works.each do |work|
            Vote.create!(work: work, user: new_user)
          end

          @winning_works.each do |work|
            Vote.create!(work: work, user: new_user)
            Vote.create!(work: work, user: new_user)
          end

          top_ten = Work.top_ten("movie")

          expect(top_ten.length).must_equal 10

          top_ten.each do |work|
            expect(@winning_works).must_include work
          end
        end

        it "selects all books if there are less than ten in db" do
          new_user = User.create!(name: "Test User")
          db_works = Work.all.filter { |work| work.category == "movie" }
          num_new_works = 5

          num_new_works.times do |count|
            @winning_work[:title] = "Winning movie #{count}"
            @winning_works << Work.create(@winning_work)
          end

          @winning_works.each do |work|
            Vote.create!(work: work, user: new_user)
          end

          top_ten = Work.top_ten("movie")

          expect(top_ten.length).must_equal num_new_works + db_works.length

          top_ten.each do |work|
            expect(@winning_works += db_works).must_include work
          end
        end

        it "returns an empty list when the db is empty" do
          Work.delete_all
          top_ten = Work.top_ten("movie")
          expect(top_ten.length).must_equal 0
          expect(top_ten).must_be_empty
        end
      end

    end

  end

end
