module Settings
  class BranchesController < BaseController
    before_action :require_settings_manage, except: :index
    before_action :set_branch, only: %i[edit update destroy]

    def index
      @branches = Branch.order(:id)
    end

    def new
      @branch = Branch.new(active: true)
    end

    def create
      @branch = Branch.new(branch_params)

      if @branch.save
        redirect_to settings_branches_path, notice: "Филиал «#{@branch.name}» создан"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @branch.update(branch_params)
        redirect_to settings_branches_path, notice: "Филиал «#{@branch.name}» обновлён"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @branch.destroy
        redirect_to settings_branches_path, notice: "Филиал удалён"
      else
        redirect_to settings_branches_path, alert: @branch.errors.full_messages.join(", ")
      end
    end

    private

    def set_branch
      @branch = Branch.find(params[:id])
    end

    def branch_params
      params.require(:branch).permit(:name, :city, :active)
    end
  end
end
