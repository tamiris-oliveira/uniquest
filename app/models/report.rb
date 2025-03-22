class Report < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  validates :correct_answers, :incorrect_answers, :total_grade, presence: true
  validates :generation_date, presence: true
end
