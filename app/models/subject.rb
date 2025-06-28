class Subject < ApplicationRecord
  has_many :questions, dependent: :restrict_with_error
  validates :name, presence: true, uniqueness: true
end
