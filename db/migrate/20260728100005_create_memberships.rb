class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.references :branch, foreign_key: true    # NULL = вся сеть (глобальный скоуп)
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :memberships, [ :user_id, :role_id, :branch_id ], unique: true
  end
end
