class CreateOutboxEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :outbox_events do |t|
      t.string :destination, null: false                  # имя WebhookEndpoint-адресата
      t.string :entity_type, null: false
      t.string :entity_id
      t.string :event, null: false
      t.jsonb :payload, null: false, default: {}
      t.string :status, null: false, default: "pending"   # pending / delivered / dead
      t.integer :attempts, null: false, default: 0
      t.text :last_error
      t.datetime :delivered_at
      t.timestamps
    end

    add_index :outbox_events, [ :destination, :status ]
    add_index :outbox_events, :status
  end
end
