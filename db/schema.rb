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

ActiveRecord::Schema[8.0].define(version: 2025_06_29_173000) do
  create_table "alternatives", charset: "utf8mb3", force: :cascade do |t|
    t.text "text"
    t.boolean "correct"
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_alternatives_on_question_id"
  end

  create_table "answers", charset: "utf8mb3", force: :cascade do |t|
    t.text "student_answer"
    t.boolean "correct"
    t.bigint "question_id", null: false
    t.bigint "attempt_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attempt_id"], name: "index_answers_on_attempt_id"
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "attempts", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "attempt_date"
    t.bigint "simulation_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "final_grade", precision: 10, scale: 2
    t.index ["simulation_id"], name: "index_attempts_on_simulation_id"
    t.index ["user_id"], name: "index_attempts_on_user_id"
  end

  create_table "corrections", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "answer_id", null: false
    t.decimal "grade", precision: 10
    t.text "feedback"
    t.datetime "correction_date"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_id"], name: "index_corrections_on_answer_id"
    t.index ["user_id"], name: "index_corrections_on_user_id"
  end

  create_table "group_simulations", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "simulation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_simulations_on_group_id"
    t.index ["simulation_id"], name: "index_group_simulations_on_simulation_id"
  end

  create_table "group_users", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "invite_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
  end

  create_table "notifications", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "message"
    t.boolean "viewed"
    t.datetime "send_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "question_simulations", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "simulation_id", null: false
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_question_simulations_on_question_id"
    t.index ["simulation_id"], name: "index_question_simulations_on_simulation_id"
  end

  create_table "questions", charset: "utf8mb3", force: :cascade do |t|
    t.text "statement"
    t.string "question_type"
    t.text "justification"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subject_id", null: false
    t.index ["subject_id"], name: "index_questions_on_subject_id"
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "reports", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "simulation_id", null: false
    t.integer "correct_answers"
    t.integer "incorrect_answers"
    t.decimal "total_grade", precision: 10
    t.datetime "generation_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["simulation_id"], name: "index_reports_on_simulation_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "simulations", charset: "utf8mb3", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "creation_date"
    t.datetime "deadline", precision: nil
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "time_limit"
    t.integer "max_attempts", default: 1
    t.index ["user_id"], name: "index_simulations_on_user_id"
  end

  create_table "subjects", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "avatar"
  end

  add_foreign_key "alternatives", "questions"
  add_foreign_key "answers", "attempts"
  add_foreign_key "answers", "questions"
  add_foreign_key "attempts", "simulations"
  add_foreign_key "attempts", "users"
  add_foreign_key "corrections", "answers"
  add_foreign_key "corrections", "users"
  add_foreign_key "group_simulations", "groups"
  add_foreign_key "group_simulations", "simulations"
  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "question_simulations", "questions"
  add_foreign_key "question_simulations", "simulations"
  add_foreign_key "questions", "users"
  add_foreign_key "reports", "simulations"
  add_foreign_key "reports", "users"
  add_foreign_key "simulations", "users"
end
