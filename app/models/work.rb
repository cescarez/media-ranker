VALID_CATEGORIES = ["album", "book", "movie"]

class Work < ApplicationRecord
  has_many :votes

  validates :category, presence: true
  validates :title, presence: true
  validates :creator, presence: true
  validates_date :publication_year, on_or_before: lambda { Date.current }

  def validate_category
    unless VALID_CATEGORIES.include? self.category
      raise ArgumentError, "Invalid category for work. Program exiting."
    else
      return self.category
    end
  end

  def self.spotlight
    return Work.all.max_by { |work| work.votes.length }
  end

  def self.top_ten(category)
    return Work.all.filter { |work| work.category == category }.max_by(10) { |work| work.votes.length }
  end

  def self.ordered_filter(category)
    raise ArgumentError, "Invalid work category, #{category}. Please enter 'album', 'book', or 'movie'." unless VALID_CATEGORIES.include? category
    return Work.all.filter { |work| work.category == category }.sort_by { |work| -work.votes.length }
  end

  def add_vote(user: nil)
    return nil if user.nil?
    return Vote.create(work: self, user: user, submit_date: Time.now)
  end

end
