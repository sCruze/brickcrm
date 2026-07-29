# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_29_100005) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "branches", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "city"
    t.datetime "created_at", null: false
    t.string "external_id"
    t.string "external_source"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["external_source", "external_id"], name: "index_branches_on_external_source_and_external_id", unique: true, where: "(external_id IS NOT NULL)"
  end

  create_table "clients", force: :cascade do |t|
    t.bigint "branch_id"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.text "notes"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_clients_on_branch_id"
    t.index ["name"], name: "index_clients_on_name"
  end

  create_table "funnels", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  create_table "inbox_events", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "entity_id"
    t.string "entity_type", null: false
    t.string "event", null: false
    t.string "event_key", null: false
    t.text "last_error"
    t.jsonb "payload", default: {}, null: false
    t.datetime "processed_at"
    t.string "source", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["source", "event_key"], name: "index_inbox_events_on_source_and_event_key", unique: true
    t.index ["status"], name: "index_inbox_events_on_status"
  end

  create_table "leads", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2
    t.bigint "assignee_id"
    t.bigint "branch_id"
    t.bigint "client_id"
    t.datetime "closed_at"
    t.string "contact_name"
    t.datetime "created_at", null: false
    t.string "email"
    t.bigint "funnel_id", null: false
    t.text "notes"
    t.string "phone"
    t.integer "position", default: 0, null: false
    t.string "source"
    t.bigint "stage_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_leads_on_assignee_id"
    t.index ["branch_id"], name: "index_leads_on_branch_id"
    t.index ["client_id"], name: "index_leads_on_client_id"
    t.index ["funnel_id"], name: "index_leads_on_funnel_id"
    t.index ["stage_id", "position"], name: "index_leads_on_stage_id_and_position"
    t.index ["stage_id"], name: "index_leads_on_stage_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.bigint "branch_id"
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["branch_id"], name: "index_memberships_on_branch_id"
    t.index ["role_id"], name: "index_memberships_on_role_id"
    t.index ["user_id", "role_id", "branch_id"], name: "index_memberships_on_user_id_and_role_id_and_branch_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "outbox_events", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.string "destination", null: false
    t.string "entity_id"
    t.string "entity_type", null: false
    t.string "event", null: false
    t.text "last_error"
    t.jsonb "payload", default: {}, null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["destination", "status"], name: "index_outbox_events_on_destination_and_status"
    t.index ["status"], name: "index_outbox_events_on_status"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.string "name", null: false
    t.jsonb "permissions", default: {}, null: false
    t.boolean "system", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_roles_on_key", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "stages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "funnel_id", null: false
    t.string "kind", default: "open", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["funnel_id", "position"], name: "index_stages_on_funnel_id_and_position"
    t.index ["funnel_id"], name: "index_stages_on_funnel_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "assignee_id"
    t.bigint "branch_id"
    t.bigint "client_id"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.date "due_on"
    t.bigint "lead_id"
    t.text "notes"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_tasks_on_assignee_id"
    t.index ["branch_id"], name: "index_tasks_on_branch_id"
    t.index ["client_id"], name: "index_tasks_on_client_id"
    t.index ["due_on"], name: "index_tasks_on_due_on"
    t.index ["lead_id"], name: "index_tasks_on_lead_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "external_uid"
    t.string "name", default: "", null: false
    t.string "password_digest"
    t.string "provider"
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["provider", "external_uid"], name: "index_users_on_provider_and_external_uid", unique: true, where: "(provider IS NOT NULL)"
  end

  create_table "webhook_endpoints", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["name"], name: "index_webhook_endpoints_on_name", unique: true
  end

  add_foreign_key "clients", "branches"
  add_foreign_key "leads", "branches"
  add_foreign_key "leads", "clients"
  add_foreign_key "leads", "funnels"
  add_foreign_key "leads", "stages"
  add_foreign_key "leads", "users", column: "assignee_id"
  add_foreign_key "memberships", "branches"
  add_foreign_key "memberships", "roles"
  add_foreign_key "memberships", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "stages", "funnels"
  add_foreign_key "tasks", "branches"
  add_foreign_key "tasks", "clients"
  add_foreign_key "tasks", "leads"
  add_foreign_key "tasks", "users", column: "assignee_id"
end
