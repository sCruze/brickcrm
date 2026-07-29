class InboxEvent < ApplicationRecord
  STATUSES = %w[pending processed failed].freeze

  validates :source, :event_key, :entity_type, :event, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }
end
