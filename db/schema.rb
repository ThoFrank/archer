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

ActiveRecord::Schema[8.0].define(version: 2025_08_07_182044) do
  create_table "Tournaments", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "place"
    t.datetime "date_start"
    t.datetime "date_end"
    t.date "season_start_date"
    t.string "status"
    t.string "email"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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

  create_table "registration_participants", force: :cascade do |t|
    t.integer "registration_id", null: false
    t.integer "participant_id", null: false
    t.index ["participant_id"], name: "index_registration_participants_on_participant_id"
    t.index ["registration_id"], name: "index_registration_participants_on_registration_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_registrations_on_tournament_id"
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

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "articles"
  add_foreign_key "participants", "target_faces"
  add_foreign_key "participants", "tournament_classes"
  add_foreign_key "registration_participants", "participants"
  add_foreign_key "registration_participants", "registrations"
  add_foreign_key "registrations", "tournaments"
  add_foreign_key "sessions", "users"
  add_foreign_key "target_faces", "tournaments"
  add_foreign_key "target_faces_tournament_classes", "target_faces"
  add_foreign_key "target_faces_tournament_classes", "tournament_classes"
  add_foreign_key "tournament_classes", "tournaments"
end
