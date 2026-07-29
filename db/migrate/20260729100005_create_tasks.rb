class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :notes
      t.date :due_on
      t.datetime :completed_at
      t.references :assignee, foreign_key: { to_table: :users }
      t.references :lead, foreign_key: true
      t.references :client, foreign_key: true
      t.references :branch, foreign_key: true
      t.timestamps
    end

    add_index :tasks, :due_on
  end
end
