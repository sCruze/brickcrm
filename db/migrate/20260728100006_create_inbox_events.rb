class CreateInboxEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :inbox_events do |t|
      t.string :source, null: false                       # источник события (по INBOUND_API_TOKENS)
      t.string :event_key, null: false                    # ключ идемпотентности от отправителя
      t.string :entity_type, null: false
      t.string :entity_id
      t.string :event, null: false                        # created / updated / deleted / ...
      t.jsonb :payload, null: false, default: {}
      t.string :status, null: false, default: "pending"   # pending / processed / failed
      t.integer :attempts, null: false, default: 0
      t.text :last_error
      t.datetime :processed_at
      t.timestamps
    end

    # ВАЖНО: дедупликация в коде обязана совпадать с этим индексом (без участия status)
    add_index :inbox_events, [ :source, :event_key ], unique: true
    add_index :inbox_events, :status
  end
end
