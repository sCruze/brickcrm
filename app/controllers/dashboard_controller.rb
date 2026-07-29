class DashboardController < ApplicationController
  before_action -> { require_permission!(:dashboard, :read) }

  def index
    leads = Lead.visible_to(current_user)
    tasks = Task.visible_to(current_user)

    @new_today = leads.where(created_at: Time.current.all_day).count
    @in_progress = leads.open_kind.count
    @month_revenue = leads.won.where(closed_at: Date.current.all_month).sum(:amount)
    @tasks_today = tasks.due_today.count
    @tasks_overdue = tasks.overdue.count

    @recent_leads = leads.includes(:stage).order(created_at: :desc).limit(6)
    @today_tasks = tasks.where(due_on: ..Date.current).todo.includes(:lead, :client).order(:due_on).limit(6)
  end
end
