class User < ApplicationRecord
  has_many :votes

  validates :name, presence: true
  validates_date :join_date, on_or_before: lambda { Date.current }
end
