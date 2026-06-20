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

ActiveRecord::Schema[8.1].define(version: 2026_06_20_090000) do
  create_table "devlogs", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "project_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["project_id"], name: "index_devlogs_on_project_id"
    t.index ["user_id"], name: "index_devlogs_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.string "demo_url"
    t.text "description"
    t.decimal "hackatime_hours", precision: 8, scale: 2
    t.string "hackatime_project"
    t.string "image_url"
    t.string "name", null: false
    t.string "repository_url"
    t.string "status", default: "not_yet_shipped", null: false
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.string "avatar"
    t.integer "clapperboards", default: 0
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "email"
    t.string "hackatime_access_token"
    t.datetime "hackatime_expires_at"
    t.string "hackatime_refresh_token"
    t.string "hackatime_uid"
    t.string "name"
    t.string "profile"
    t.boolean "referral_paid"
    t.integer "referrals", default: 0
    t.string "referred_by"
    t.string "slack_id"
    t.string "token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.string "verification_status"
  end

  add_foreign_key "devlogs", "projects"
  add_foreign_key "devlogs", "users"
  add_foreign_key "projects", "users"
end
