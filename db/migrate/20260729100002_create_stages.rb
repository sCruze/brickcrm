class CreateStages < ActiveRecord::Migration[8.1]
  def change
    create_table :stages do |t|
      t.references :funnel, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.string :kind, null: false, default: "open"   # open / won / lost
      t.timestamps
    end

    add_index :stages, [ :funnel_id, :position ]
  end
end
