class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :attempt
  has_many :corrections, dependent: :destroy

  validates :student_answer, presence: true
  validates :correct, inclusion: { in: [ true, false ] }
end
