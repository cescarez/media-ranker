require "test_helper"

describe Work do
  let (:work) { works(:album1) }
  let (:other_work) { works(:book1) }
  let (:another_work) { works(:movie1) }

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
      new_user1 = users(:user1)
      new_user2 = users(:user2)
      vote1 = Vote.create!(work: work, user: new_user1)
      vote2 = Vote.create!(work: work, user: new_user2)
      vote3 = Vote.create!(work: other_work, user: new_user1)

      expect(work.votes.count).must_equal 2
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

    before do
      @user1 = users(:user1)
      @user2 = users(:user2)
    end

    describe "spotlight" do
      it "will select the work with the most votes" do
        vote1 = Vote.create!(work: work, user: @user1)
        vote2 = Vote.create!(work: other_work, user: @user2)
        vote3 = Vote.create!(work: other_work, user: @user1)
        vote4 = Vote.create!(work: another_work, user: @user1)

        top_work = Work.spotlight

        expect(top_work.id).must_equal other_work.id
      end

      it "in cases of ties, will select the work added to db first" do
        vote1 = Vote.create!(work: another_work, user: @user1)
        vote2 = Vote.create!(work: work, user: @user2)
        vote3 = Vote.create!(work: other_work, user: @user1)
        vote4 = Vote.create!(work: another_work, user: @user1)
        vote5 = Vote.create!(work: work, user: @user2)
        vote6 = Vote.create!(work: other_work, user: @user1)

        top_work = Work.spotlight

        expect(top_work.id).must_equal work.id
      end
    end

    describe "top_ten" do

      before do
        @user = users(:user1)

        @losing_works = []
        @winning_works = []

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
      end

      describe "albums" do
        before do
          @winning_work.update(category: "album")
          @losing_work.update(category: "album")
        end

        it "selects top ten albums based on votes" do
          12.times do |count|
            @losing_work[:title] = "Losing album #{count}"
            @winning_work[:title] = "Winning album #{count}"
            @losing_works << Work.create(@losing_work)
            @winning_works << Work.create(@winning_work)
          end

          @losing_works.each do |work|
            Vote.create!(work: work, user: @user)
          end

          @winning_works.each do |work|
            Vote.create!(work: work, user: @user)
            Vote.create!(work: work, user: @user)
          end

          top_ten = Work.top_ten("album")

          expect(top_ten.length).must_equal 10

          top_ten.each do |work|
            expect(@winning_works).must_include work
          end
        end

        it "selects all albums if there are less than ten in db" do
          db_works = Work.all.filter { |work| work.category == "album" }
          num_new_works = 5

          num_new_works.times do |count|
            @winning_work[:title] = "Winning album #{count}"
            @winning_works << Work.create(@winning_work)
          end

          @winning_works.each do |work|
            Vote.create!(work: work, user: @user)
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
          @winning_work.update(category: "book")
          @losing_work.update(category: "book")
        end

        it "selects top ten books based on votes" do

          12.times do |count|
            @losing_work[:title] = "Losing book #{count}"
            @winning_work[:title] = "Winning book #{count}"
            @losing_works << Work.create(@losing_work)
            @winning_works << Work.create(@winning_work)
          end

          @losing_works.each do |work|
            Vote.create!(work: work, user: @user)
          end

          @winning_works.each do |work|
            Vote.create!(work: work, user: @user)
            Vote.create!(work: work, user: @user)
          end

          top_ten = Work.top_ten("book")

          expect(top_ten.length).must_equal 10

          top_ten.each do |work|
            expect(@winning_works).must_include work
          end
        end

        it "selects all books if there are less than ten in db" do
          db_works = Work.all.filter { |work| work.category == "book" }
          num_new_works = 5

          num_new_works.times do |count|
            @winning_work[:title] = "Winning book #{count}"
            @winning_works << Work.create(@winning_work)
          end

          @winning_works.each do |work|
            Vote.create!(work: work, user: @user)
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
          @winning_work.update(category: "movie")
          @losing_work.update(category: "movie")
        end

        it "selects top ten movies based on votes" do
          12.times do |count|
            @losing_work[:title] = "Losing movie #{count}"
            @winning_work[:title] = "Winning movie #{count}"
            @losing_works << Work.create(@losing_work)
            @winning_works << Work.create(@winning_work)
          end

          @losing_works.each do |work|
            Vote.create!(work: work, user: @user)
          end

          @winning_works.each do |work|
            Vote.create!(work: work, user: @user)
            Vote.create!(work: work, user: @user)
          end

          top_ten = Work.top_ten("movie")

          expect(top_ten.length).must_equal 10

          top_ten.each do |work|
            expect(@winning_works).must_include work
          end
        end

        it "selects all books if there are less than ten in db" do
          db_works = Work.all.filter { |work| work.category == "movie" }
          num_new_works = 5

          num_new_works.times do |count|
            @winning_work[:title] = "Winning movie #{count}"
            @winning_works << Work.create(@winning_work)
          end

          @winning_works.each do |work|
            Vote.create!(work: work, user: @user)
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

    describe "ordered_filter" do
      describe "albums" do
        before do
          work.update(category: "album")
          other_work.update(category: "album")
          another_work.update(category: "album")
        end

        it "returns an ordered list of albums by vote" do
          2.times do
            Vote.create!(work: work, user: @user1)
          end
          3.times do
            Vote.create!(work: other_work, user: @user2)
          end
          5.times do
            Vote.create!(work: another_work, user: @user2)
          end

          albums_by_vote = Work.ordered_filter("album")

          albums_by_vote.each_with_index do |work, index|

            if index > 0
              less_than_previous = work.votes.length < albums_by_vote[index - 1].votes.length
              expect(less_than_previous).must_equal true
            end

            if albums_by_vote[index + 1]
              greater_than_next = work.votes.length > albums_by_vote[index + 1].votes.length
              expect(greater_than_next).must_equal true
            end

          end

        end


      end
      ########
    end

    describe "add_vote" do

    end

  end

end
