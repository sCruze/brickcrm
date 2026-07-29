class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.references :funnel, null: false, foreign_key: true
      t.references :stage, null: false, foreign_key: true
      t.references :client, foreign_key: true
      t.references :branch, foreign_key: true
      t.references :assignee, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.string :contact_name
      t.string :phone
      t.string :email
      t.string :source
      t.decimal :amount, precision: 12, scale: 2
      t.integer :position, null: false, default: 0
      t.text :notes
      t.datetime :closed_at                 # проставляется при переходе в won/lost
      t.timestamps
    end

    add_index :leads, [ :stage_id, :position ]
  end
end
