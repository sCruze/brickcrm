class TasksController < ApplicationController
  before_action -> { require_permission!(:tasks, :read) }, only: %i[index]
  before_action -> { require_permission!(:tasks, :write) }, except: %i[index]
  before_action :set_task, only: %i[edit update destroy toggle]

  def index
    scope = Task.visible_to(current_user).includes(:assignee, :lead, :client)
    @overdue = scope.overdue.order(:due_on)
    @today = scope.due_today.order(:id)
    @upcoming = scope.upcoming.order(:due_on).limit(30)
    @undated = scope.undated.order(:id)
    @done = scope.done.order(completed_at: :desc).limit(10)
  end

  def new
    @task = Task.new(due_on: Date.current, assignee: current_user,
                     lead_id: params[:lead_id], client_id: params[:client_id])
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      redirect_to safe_return_path || tasks_path, notice: "Задача создана"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to tasks_path, notice: "Задача обновлена"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "Задача удалена"
  end

  # PATCH /tasks/:id/toggle — выполнено/не выполнено
  def toggle
    @task.toggle_done!
    redirect_back fallback_location: tasks_path
  end

  private

  def set_task
    @task = Task.visible_to(current_user).find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :notes, :due_on, :assignee_id, :lead_id, :client_id, :branch_id)
  end

  # Возврат только на внутренние адреса приложения
  def safe_return_path
    url_from(params[:return_to])
  end
end
