class Question < ApplicationRecord
  belongs_to :user
  has_many :alternatives, dependent: :destroy
  has_many :question_simulations, dependent: :destroy

  validates :statement, :question_type, presence: true
  validates :question_type, inclusion: { in: [ "Objetiva", "Discursiva" ] }
end
