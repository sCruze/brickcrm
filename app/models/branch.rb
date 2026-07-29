class Branch < ApplicationRecord
  has_many :memberships, dependent: :restrict_with_error
  has_many :leads, dependent: :nullify
  has_many :clients, dependent: :nullify
  has_many :tasks, dependent: :nullify

  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
