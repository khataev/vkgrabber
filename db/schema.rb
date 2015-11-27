# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151127180504) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachments", force: :cascade do |t|
    t.jsonb    "json"
    t.integer  "attachmentable_id"
    t.string   "attachmentable_type"
    t.text     "attachment_type"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "attachments", ["attachmentable_type", "attachmentable_id"], name: "index_attachments_on_attachmentable_type_and_attachmentable_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.jsonb    "json"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "comments", ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.jsonb    "json"
    t.integer  "vgroup_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "posts", ["vgroup_id"], name: "index_posts_on_vgroup_id", using: :btree

  create_table "rawfiles", force: :cascade do |t|
    t.binary   "data"
    t.text     "tag"
    t.integer  "attachment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "rawfiles", ["attachment_id"], name: "index_rawfiles_on_attachment_id", using: :btree

  create_table "topics", force: :cascade do |t|
    t.jsonb    "json"
    t.integer  "vgroup_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "topics", ["vgroup_id"], name: "index_topics_on_vgroup_id", using: :btree

  create_table "vgroups", force: :cascade do |t|
    t.integer  "vk_id"
    t.jsonb    "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "posts", "vgroups"
  add_foreign_key "rawfiles", "attachments"
  add_foreign_key "topics", "vgroups"
end
