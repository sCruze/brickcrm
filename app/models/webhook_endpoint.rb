class WebhookEndpoint < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, format: { with: %r{\Ahttps?://}, message: "должен начинаться с http(s)://" }

  scope :active, -> { where(active: true) }
end
