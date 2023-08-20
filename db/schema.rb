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

ActiveRecord::Schema[7.0].define(version: 2023_08_16_065656) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "title", limit: 100
    t.string "purchase_link"
    t.string "file_path"
    t.string "image_path"
    t.string "embeddings_path"
    t.string "pages_path"
    t.text "default_question"
    t.text "context_header"
    t.text "context_qa"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_books_on_title", unique: true
  end

  create_table "lucky_questions", force: :cascade do |t|
    t.string "question", limit: 140, null: false
    t.bigint "book_id"
    t.index ["book_id"], name: "index_lucky_questions_on_book_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "question", limit: 140, null: false
    t.text "context"
    t.text "answer"
    t.integer "ask_count", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "book_id"
    t.index ["book_id"], name: "index_questions_on_book_id"
  end

  add_foreign_key "lucky_questions", "books"
  add_foreign_key "questions", "books"
end
