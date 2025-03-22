class QuestionSimulation < ApplicationRecord
  belongs_to :simulation
  belongs_to :question

  validates :simulation_id, presence: true
  validates :question_id, presence: true
end
