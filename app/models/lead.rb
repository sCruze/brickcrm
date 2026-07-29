class Lead < ApplicationRecord
  include BranchScoped

  belongs_to :funnel
  belongs_to :stage
  belongs_to :client, optional: true
  belongs_to :branch, optional: true
  belongs_to :assignee, class_name: "User", optional: true
  has_many :tasks, dependent: :nullify

  validates :title, presence: true
  validate :stage_belongs_to_funnel

  before_save :sync_closed_at, if: :stage_id_changed?

  scope :ordered, -> { order(:position, :id) }
  scope :open_kind, -> { joins(:stage).where(stages: { kind: "open" }) }
  scope :won, -> { joins(:stage).where(stages: { kind: "won" }) }
  scope :lost, -> { joins(:stage).where(stages: { kind: "lost" }) }

  def move_to!(new_stage)
    update!(stage: new_stage, position: (new_stage.leads.maximum(:position) || 0) + 1)
  end

  private

  def stage_belongs_to_funnel
    return if stage.nil? || funnel.nil? || stage.funnel_id == funnel_id

    errors.add(:stage, "не принадлежит выбранной воронке")
  end

  def sync_closed_at
    self.closed_at = stage&.open? ? nil : Time.current
  end
end
