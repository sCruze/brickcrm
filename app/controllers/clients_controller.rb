class ClientsController < ApplicationController
  before_action -> { require_permission!(:clients, :read) }, only: %i[index show]
  before_action -> { require_permission!(:clients, :write) }, except: %i[index show]
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @query = params[:q]
    @clients = Client.visible_to(current_user).search(@query).order(:name).limit(200)
  end

  def show
    @leads = @client.leads.includes(:stage, :funnel).order(created_at: :desc)
    @tasks = @client.tasks.order(:due_on)
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to client_path(@client), notice: "Клиент «#{@client.name}» создан"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to client_path(@client), notice: "Клиент обновлён"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path, notice: "Клиент удалён"
  end

  private

  def set_client
    @client = Client.visible_to(current_user).find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :phone, :email, :branch_id, :notes)
  end
end
