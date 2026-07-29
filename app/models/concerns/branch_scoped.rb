# Row-level видимость по филиалу: записи без филиала (branch_id NULL)
# считаются общими и видны всем; глобальный membership видит всё.
module BranchScoped
  extend ActiveSupport::Concern

  included do
    scope :visible_to, ->(user) {
      user&.global_access? ? all : where(branch_id: [ nil, *user&.branch_ids_in_scope ])
    }
  end
end
