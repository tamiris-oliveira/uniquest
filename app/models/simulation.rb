class Simulation < ApplicationRecord
  belongs_to :user

  has_many :group_simulations, dependent: :destroy
  has_many :groups, through: :group_simulations

  has_many :question_simulations, dependent: :destroy
  has_many :questions, through: :question_simulations

  has_many :attempts, dependent: :destroy
  has_many :reports, dependent: :destroy

  validates :title, :deadline, presence: true
  validates :time_limit, numericality: { greater_than: 0 }
  validates :max_attempts, numericality: { greater_than: 0 }
end
