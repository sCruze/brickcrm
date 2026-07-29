class Role < ApplicationRecord
  ACTIONS = %w[read write manage].freeze
  SECTIONS = %w[dashboard leads clients tasks calendar reports settings roles sync].freeze

  has_many :memberships, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true

  def allows?(section, action)
    Array(permissions[section.to_s]).include?(action.to_s)
  end

  def self.full_permissions
    SECTIONS.index_with { ACTIONS.dup }
  end
end
