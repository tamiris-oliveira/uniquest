class Simulation < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many :question_simulations, dependent: :destroy
  has_many :questions, through: :question_simulations
  has_many :attempts, dependent: :destroy

  validates :title, :deadline, presence: true
end
