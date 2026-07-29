class CreateWebhookEndpoints < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_endpoints do |t|
      t.string :name, null: false          # совпадает с outbox_events.destination
      t.string :url, null: false
      t.string :token                      # Bearer-токен исходящих запросов
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :webhook_endpoints, :name, unique: true
  end
end
