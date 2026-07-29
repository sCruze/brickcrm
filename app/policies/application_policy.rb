class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # Row-level скоуп по филиалу: глобальный membership видит всё,
    # остальные — только записи своих филиалов (если у модели есть branch_id).
    def resolve
      return scope.all if user&.global_access?

      if scope.respond_to?(:column_names) && scope.column_names.include?("branch_id")
        scope.where(branch_id: user&.branch_ids_in_scope || [])
      else
        scope.none
      end
    end

    private

    attr_reader :user, :scope
  end

  private

  def allowed?(section, action)
    user.present? && user.permission?(section, action)
  end
end
