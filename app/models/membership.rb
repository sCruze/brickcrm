class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :role
  belongs_to :branch, optional: true   # NULL = вся сеть

  validates :role_id, uniqueness: { scope: [ :user_id, :branch_id ] }
end
