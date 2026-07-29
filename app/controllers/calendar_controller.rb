class CalendarController < ApplicationController
  before_action -> { require_permission!(:calendar, :read) }

  def index
    @month = begin
      Date.strptime(params[:month].to_s, "%Y-%m")
    rescue ArgumentError
      Date.current.beginning_of_month
    end

    from = @month.beginning_of_week(:monday)
    to = @month.end_of_month.end_of_week(:monday)
    @weeks = (from..to).to_a.each_slice(7).to_a

    @tasks_by_day = Task.visible_to(current_user)
                        .todo
                        .where(due_on: from..to)
                        .includes(:assignee)
                        .group_by(&:due_on)
  end
end
