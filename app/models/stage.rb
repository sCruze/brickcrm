class Stage < ApplicationRecord
  KINDS = %w[open won lost].freeze

  belongs_to :funnel
  has_many :leads, dependent: :restrict_with_error

  validates :name, presence: true
  validates :kind, inclusion: { in: KINDS }

  scope :open_kind, -> { where(kind: "open") }

  def open? = kind == "open"
  def won? = kind == "won"
  def lost? = kind == "lost"
end
