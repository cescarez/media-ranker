require "test_helper"

describe Work do
  let (:work) { works(:album1) }
  let (:other_work) { works(:book1) }
  let (:another_work) { works(:movie1) }
  let (:user1) { users(:user1) }
  let (:user2) { users(:user2) }

  describe "instantiation" do
    it "can be instantiated" do
      expect(work.valid?).must_equal true
    end

    it "will have the required fields" do
      [:category, :title, :creator, :publication_year, :description].each do |field|
        expect(work).must_respond_to field
      end
    end
  end

  describe "relationships" do
    it "can have multiple votes" do
      expect(work.votes.count).must_equal 10 #see works.yml
      work.votes.each do |vote|
        expect(vote).must_be_instance_of Vote
      end
    end
  end

  describe "validates" do
    it "must have a category" do
      work.category = nil
      expect(work.valid?).must_equal false
    end
    it "must have a title" do
      work.title = nil
      expect(work.valid?).must_equal false
    end
    it "must have a creator" do
      work.creator = nil
      expect(work.valid?).must_equal false
    end
    it "must have a publication year" do
      work.publication_year = nil
      expect(work.valid?).must_equal false
    end
    it "validation error message gets stored for required fields" do
      work.category = nil
      work.title = nil
      work.creator = nil
      work.publication_year = nil
      work.description = nil
      work.save
      expect(work.errors.messages).must_include :category
      expect(work.errors.messages).must_include :title
      expect(work.errors.messages).must_include :creator
      expect(work.errors.messages).must_include :publication_year
    end
  end

  describe "custom methods" do
    describe "validate_category" do
      it "will raise an exception for invalid string inputs for category" do
        work.category = "test_fail"
        expect {
          work.validate_category
        }.must_raise ArgumentError
      end
      it "will raise an exception for empty string inputs for category" do
        work.category = ""
        expect {
          work.validate_category
        }.must_raise ArgumentError
      end
    end


    describe "spotlight" do
      it "will select the work with the most votes" do
        Vote.create!(work: other_work, user: user1) #adds 11th vote for other_work == works(:book1)

        top_work = Work.spotlight

        expect(top_work.id).must_equal other_work.id
      end

      it "in cases of ties, will select the work added to db earliest" do
        #works.yml currently has 10 voces for each works(:album1), works(:book1), works(:movie1)
        top_work = Work.spotlight

        expect(top_work.id).must_equal work.id #see works.yml; album1 is first
      end
    end

    describe "top_ten" do
      before do
        @losing_works = []
        @winning_works = []
      end

      describe "albums" do
        before do
          @category = "album"
        end

        it "selects top ten albums based on votes" do
          10.times do |count|
            @losing_works << works("losing_#{@category}#{count + 1}".to_sym)
            @winning_works << works("winning_#{@category}#{count + 1}".to_sym)
          end

          @losing_works.each do |losing_work|
            Vote.create!(work: losing_work, user: user1)
          end
          @winning_works.each do |winning_work|
            count = 0
            until count > work.votes.length do
              Vote.create!(work: winning_work, user: user1)
              count += 1
            end
          end

          top_ten = Work.top_ten(@category)

          expect(top_ten.length).must_equal 10

          top_ten.each do |top_work|
            expect(@winning_works).must_include top_work
          end
        end

        it "returns an empty list when the db is empty" do
          Work.delete_all
          top_ten = Work.top_ten(@category)
          expect(top_ten.length).must_equal 0
          expect(top_ten).must_be_empty
        end
      end

      describe "books" do
        before do
          @category = "book"
        end

        it "selects top ten albums based on votes" do
          10.times do |count|
            @losing_works << works("losing_#{@category}#{count + 1}".to_sym)
            @winning_works << works("winning_#{@category}#{count + 1}".to_sym)
          end

          @losing_works.each do |losing_work|
            Vote.create!(work: losing_work, user: user1)
          end
          @winning_works.each do |winning_work|
            count = 0
            until count > work.votes.length do
              Vote.create!(work: winning_work, user: user1)
              count += 1
            end
          end

          top_ten = Work.top_ten(@category)

          expect(top_ten.length).must_equal 10

          top_ten.each do |top_work|
            expect(@winning_works).must_include top_work
          end
        end

        it "returns an empty list when the db is empty" do
          Work.delete_all
          top_ten = Work.top_ten(@category)
          expect(top_ten.length).must_equal 0
          expect(top_ten).must_be_empty
        end
      end

      describe "movies" do
        before do
          @category = "book"
        end

        it "selects top ten albums based on votes" do
          10.times do |count|
            @losing_works << works("losing_#{@category}#{count + 1}".to_sym)
            @winning_works << works("winning_#{@category}#{count + 1}".to_sym)
          end

          @losing_works.each do |losing_work|
            Vote.create!(work: losing_work, user: user1)
          end
          @winning_works.each do |winning_work|
            count = 0
            until count > work.votes.length do
              Vote.create!(work: winning_work, user: user1)
              count += 1
            end
          end

          top_ten = Work.top_ten(@category)

          expect(top_ten.length).must_equal 10

          top_ten.each do |top_work|
            expect(@winning_works).must_include top_work
          end
        end

        it "returns an empty list when the db is empty" do
          Work.delete_all
          top_ten = Work.top_ten(@category)
          expect(top_ten.length).must_equal 0
          expect(top_ten).must_be_empty
        end
      end

    end

    describe "ordered_filter" do
      describe "albums" do
        it "returns an ordered list of albums by vote" do
          2.times do
            Vote.create!(work: works(:winning_album3), user: user1)
          end
          3.times do
            Vote.create!(work: works(:winning_album2), user: user1)
          end
          5.times do
            Vote.create!(work: works(:winning_album1), user: user2)
          end

          albums_by_vote = Work.ordered_filter("album")

          albums_by_vote.each_with_index do |work, index|
            if index > 0
              less_than_previous = work.votes.length <= albums_by_vote[index - 1].votes.length
              expect(less_than_previous).must_equal true
            end
            if albums_by_vote[index + 1]
              greater_than_next = work.votes.length >= albums_by_vote[index + 1].votes.length
              expect(greater_than_next).must_equal true
            end
          end
        end

        it "returns an empty list if there are not works of that type in the db" do
          Work.delete_all
          albums_by_vote = Work.ordered_filter("album")
          expect(albums_by_vote).must_be_empty
        end
      end

      ########
      describe "books" do
        it "returns an ordered list of books by vote" do
          2.times do
            Vote.create!(work: works(:winning_book3), user: user1)
          end
          3.times do
            Vote.create!(work: works(:winning_book2), user: user1)
          end
          5.times do
            Vote.create!(work: works(:winning_book1), user: user2)
          end

          books_by_vote = Work.ordered_filter("book")

          books_by_vote.each_with_index do |work, index|
            if index > 0
              less_than_previous = work.votes.length <= books_by_vote[index - 1].votes.length
              expect(less_than_previous).must_equal true
            end
            if books_by_vote[index + 1]
              greater_than_next = work.votes.length >= books_by_vote[index + 1].votes.length
              expect(greater_than_next).must_equal true
            end
          end
        end

        it "returns an empty list if there are not works of that type in the db" do
          Work.delete_all
          books_by_vote = Work.ordered_filter("book")
          expect(books_by_vote).must_be_empty
        end
      end

      ########
      describe "movies" do
        it "returns an ordered list of books by vote" do
          2.times do
            Vote.create!(work: works(:winning_movie3), user: user1)
          end
          3.times do
            Vote.create!(work: works(:winning_movie2), user: user1)
          end
          5.times do
            Vote.create!(work: works(:winning_movie1), user: user2)
          end

        movies_by_vote = Work.ordered_filter("movie")

        movies_by_vote.each_with_index do |work, index|
          if index > 0
            less_than_previous = work.votes.length <= movies_by_vote[index - 1].votes.length
            expect(less_than_previous).must_equal true
          end
          if movies_by_vote[index + 1]
            greater_than_next = work.votes.length >= movies_by_vote[index + 1].votes.length
            expect(greater_than_next).must_equal true
          end
        end
      end

        it "returns an empty list if there are not works of that type in the db" do
          Work.delete_all
          movies_by_vote = Work.ordered_filter("movie")
          expect(movies_by_vote).must_be_empty
        end
      end

      it "raises an Argument Error if any category other than 'album', 'book', or 'category' is entered" do
        expect {
          Work.ordered_filter("krabby_patties")
        }.must_raise ArgumentError
      end
    end

    describe "add_vote" do
      it "adds a vote for an existing user" do
        vote = nil

        expect {
          vote = work.add_vote(user: user1)
        }.must_differ "Vote.count", 1

        expect(vote).must_be_instance_of Vote
      end

      it "returns nil for a non-existing user" do
        vote = nil

        expect {
          vote = work.add_vote(user: nil)
        }.wont_change "Vote.count"

        expect(vote).must_be_nil
      end
    end

  end

end
