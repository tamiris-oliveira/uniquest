class Question < ApplicationRecord
  belongs_to :user
  belongs_to :subject
  has_many :alternatives, dependent: :destroy
  has_many :question_simulations, dependent: :destroy
  has_many :simulations, through: :question_simulations


  validates :statement, :question_type, presence: true
  validates :question_type, inclusion: { in: [ "Objetiva", "Discursiva" ] }
  accepts_nested_attributes_for :alternatives, allow_destroy: true
end
