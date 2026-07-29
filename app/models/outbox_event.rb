class OutboxEvent < ApplicationRecord
  STATUSES = %w[pending delivered dead].freeze
  MAX_ATTEMPTS = 10

  validates :destination, :entity_type, :event, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }

  def register_failure!(message)
    next_attempts = attempts + 1
    update!(
      attempts: next_attempts,
      last_error: message.to_s.truncate(1000),
      status: next_attempts >= MAX_ATTEMPTS ? "dead" : "pending"
    )
  end
end
