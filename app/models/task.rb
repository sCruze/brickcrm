class Task < ApplicationRecord
  include BranchScoped

  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :lead, optional: true
  belongs_to :client, optional: true
  belongs_to :branch, optional: true

  validates :title, presence: true

  scope :todo, -> { where(completed_at: nil) }
  scope :done, -> { where.not(completed_at: nil) }
  scope :overdue, -> { todo.where(due_on: ...Date.current) }
  scope :due_today, -> { todo.where(due_on: Date.current) }
  scope :upcoming, -> { todo.where(due_on: Date.current.next_day..) }
  scope :undated, -> { todo.where(due_on: nil) }

  def done? = completed_at.present?

  def toggle_done!
    update!(completed_at: done? ? nil : Time.current)
  end
end
