class ReportsController < ApplicationController
  before_action -> { require_permission!(:reports, :read) }

  def index
    @funnels = Funnel.active.ordered
    @funnel = @funnels.find { |f| f.id == params[:funnel_id].to_i } || @funnels.first
    leads = Lead.visible_to(current_user)
    scoped = @funnel ? leads.where(funnel: @funnel) : leads.none

    @stage_counts = @funnel ? @funnel.stages.map { |s| [ s, scoped.where(stage: s).count ] } : []
    @max_stage_count = [ @stage_counts.map(&:last).max.to_i, 1 ].max

    @won = scoped.won.count
    @lost = scoped.lost.count
    closed = @won + @lost
    @conversion = closed.positive? ? (@won * 100.0 / closed).round : nil

    @month_revenue = scoped.won.where(closed_at: Date.current.all_month).sum(:amount)
    @sources = scoped.where.not(source: [ nil, "" ]).group(:source).order(count_all: :desc).limit(5).count

    @tasks_done_month = Task.visible_to(current_user).done.where(completed_at: Date.current.all_month).count
  end
end
