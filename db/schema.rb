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

ActiveRecord::Schema[8.0].define(version: 2025_03_29_191408) do
  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string "commenter"
    t.text "body"
    t.integer "article_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_comments_on_article_id"
  end

  create_table "participants", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "Tournament_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "dob"
    t.integer "tournament_class_id"
    t.integer "target_face_id"
    t.index ["Tournament_id"], name: "index_participants_on_Tournament_id"
    t.index ["target_face_id"], name: "index_participants_on_target_face_id"
    t.index ["tournament_class_id"], name: "index_participants_on_tournament_class_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "target_faces", force: :cascade do |t|
    t.string "name"
    t.integer "distance"
    t.integer "size"
    t.integer "tournament_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_target_faces_on_tournament_id"
  end

  create_table "target_faces_tournament_classes", force: :cascade do |t|
    t.integer "tournament_class_id"
    t.integer "target_face_id"
    t.index ["target_face_id"], name: "index_target_faces_tournament_classes_on_target_face_id"
    t.index ["tournament_class_id"], name: "index_target_faces_tournament_classes_on_tournament_class_id"
  end

  create_table "tournament_classes", force: :cascade do |t|
    t.string "name"
    t.integer "age_start"
    t.integer "age_end"
    t.integer "tournament_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_tournament_classes_on_tournament_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.string "name"
    t.text "intro"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "place"
    t.datetime "date_start"
    t.datetime "date_end"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "comments", "articles"
  add_foreign_key "participants", "target_faces"
  add_foreign_key "participants", "tournament_classes"
  add_foreign_key "sessions", "users"
  add_foreign_key "target_faces", "tournaments"
  add_foreign_key "target_faces_tournament_classes", "target_faces"
  add_foreign_key "target_faces_tournament_classes", "tournament_classes"
  add_foreign_key "tournament_classes", "tournaments"
end
