class Branch < ApplicationRecord
  has_many :memberships, dependent: :restrict_with_error

  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
