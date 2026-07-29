class Funnel < ApplicationRecord
  has_many :stages, -> { order(:position) }, dependent: :destroy
  has_many :leads, dependent: :restrict_with_error

  validates :name, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :id) }

  def first_stage = stages.first
end
