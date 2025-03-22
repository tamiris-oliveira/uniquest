class Attempt < ApplicationRecord
  belongs_to :simulation
  belongs_to :user
  has_many :answers, dependent: :destroy

  validates :attempt_date, presence: true
end
