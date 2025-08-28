class Correction < ApplicationRecord
  belongs_to :answer
  belongs_to :user

  validates :grade, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true
  validates :feedback, presence: true, allow_nil: true
end
