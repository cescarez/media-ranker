class User < ApplicationRecord
  has_many :votes

  validates :name, presence: true
end
