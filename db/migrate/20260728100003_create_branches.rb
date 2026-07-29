class CreateBranches < ActiveRecord::Migration[8.1]
  def change
    create_table :branches do |t|
      t.string :name, null: false
      t.string :city
      t.string :external_source              # внешняя система-источник (при синхронизации)
      t.string :external_id                  # id филиала во внешней системе
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :branches, [ :external_source, :external_id ], unique: true, where: "external_id IS NOT NULL"
  end
end
