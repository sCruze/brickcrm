class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      # permissions: { "leads" => ["read", "write"], "settings" => ["manage"], ... }
      t.string :key, null: false
      t.string :name, null: false
      t.jsonb :permissions, null: false, default: {}
      t.boolean :system, null: false, default: false
      t.timestamps
    end

    add_index :roles, :key, unique: true
  end
end
