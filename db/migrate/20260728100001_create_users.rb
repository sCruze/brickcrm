class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false, default: ""
      t.string :email, null: false
      t.string :password_digest              # NULL у SSO-аккаунтов
      t.string :provider                     # NULL = локальный пароль; иначе имя SSO-провайдера
      t.string :external_uid                 # id пользователя во внешней системе
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :users, "lower(email)", unique: true, name: "index_users_on_lower_email"
    add_index :users, [ :provider, :external_uid ], unique: true, where: "provider IS NOT NULL"
  end
end
