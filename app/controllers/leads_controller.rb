class LeadsController < ApplicationController
  before_action -> { require_permission!(:leads, :read) }, only: %i[index show]
  before_action -> { require_permission!(:leads, :write) }, except: %i[index show]
  before_action :set_lead, only: %i[show edit update destroy move]

  def index
    @funnels = Funnel.active.ordered
    @funnel = @funnels.find { |f| f.id == params[:funnel_id].to_i } || @funnels.first
    return unless @funnel

    @stages = @funnel.stages
    leads = Lead.visible_to(current_user).where(funnel: @funnel).includes(:assignee, :client).ordered
    @leads_by_stage = leads.group_by(&:stage_id)
  end

  def show
    @tasks = @lead.tasks.order(:due_on)
  end

  def new
    @lead = Lead.new(funnel_id: params[:funnel_id], branch_id: current_user.branch_ids_in_scope.first)
  end

  def create
    @lead = Lead.new(lead_params)
    @lead.funnel ||= Funnel.active.ordered.first
    @lead.stage = @lead.funnel&.first_stage
    @lead.position = (@lead.stage&.leads&.maximum(:position) || 0) + 1

    if @lead.save
      redirect_to leads_path(funnel_id: @lead.funnel_id), notice: "Лид «#{@lead.title}» создан"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @lead.update(lead_params.merge(stage_id: params[:lead][:stage_id].presence || @lead.stage_id))
      redirect_to lead_path(@lead), notice: "Лид обновлён"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lead.destroy
    redirect_to leads_path(funnel_id: @lead.funnel_id), notice: "Лид удалён"
  end

  # PATCH /leads/:id/move — перенос на доске (drag&drop)
  def move
    stage = @lead.funnel.stages.find(params[:stage_id])
    @lead.move_to!(stage)
    head :ok
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    head :unprocessable_entity
  end

  private

  def set_lead
    @lead = Lead.visible_to(current_user).find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(:funnel_id, :title, :contact_name, :phone, :email, :source,
                                 :amount, :client_id, :branch_id, :assignee_id, :notes)
  end
end
