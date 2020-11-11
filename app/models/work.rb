class Work < ApplicationRecord
  has_many :votes

  validates :category, presence: true
  validates :title, presence: true
  validates :creator, presence: true
  validates :publication_year, presence: true #TODO: if time, add date validation beyond presence
end
