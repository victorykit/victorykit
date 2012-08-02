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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120802164454) do

  create_table "bounced_emails", :force => true do |t|
    t.text     "raw_content"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "sent_email_id"
  end

  create_table "email_experiments", :force => true do |t|
    t.integer  "sent_email_id"
    t.string   "goal"
    t.string   "key"
    t.string   "choice"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "facebook_actions", :force => true do |t|
    t.integer  "member_id"
    t.integer  "petition_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "type"
    t.string   "action_id"
  end

  add_index "facebook_actions", ["member_id"], :name => "index_likes_on_member_id"
  add_index "facebook_actions", ["petition_id"], :name => "index_likes_on_petition_id"

  create_table "facebook_share_widget_shares", :force => true do |t|
    t.string   "user_facebook_id"
    t.string   "friend_facebook_id"
    t.string   "url"
    t.text     "message"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "facebook_share_widget_shares", ["user_facebook_id", "friend_facebook_id", "url"], :name => "unique_share", :unique => true

  create_table "last_updated_unsubscribes", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "is_locked",  :null => false
  end

  create_table "mailer_process_trackers", :force => true do |t|
    t.boolean  "is_locked"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "members", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "members", ["email"], :name => "index_members_on_email", :unique => true

  create_table "petition_images", :force => true do |t|
    t.text     "url",         :null => false
    t.integer  "petition_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "petition_titles", :force => true do |t|
    t.text     "title",       :null => false
    t.string   "title_type",  :null => false
    t.integer  "petition_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "petitions", :force => true do |t|
    t.text     "title",                                   :null => false
    t.text     "description",                             :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "owner_id"
    t.boolean  "to_send",              :default => false
    t.string   "ip_address"
    t.text     "facebook_description"
    t.string   "short_summary"
  end

  create_table "sent_emails", :force => true do |t|
    t.string   "email",        :null => false
    t.integer  "member_id",    :null => false
    t.integer  "petition_id",  :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "signature_id"
    t.datetime "opened_at"
    t.datetime "clicked_at"
  end

  create_table "signatures", :force => true do |t|
    t.string   "name",           :null => false
    t.string   "email",          :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "petition_id",    :null => false
    t.string   "ip_address",     :null => false
    t.string   "user_agent",     :null => false
    t.string   "browser_name"
    t.boolean  "created_member"
    t.integer  "member_id",      :null => false
    t.integer  "referer_id"
    t.string   "reference_type"
    t.text     "referring_url"
  end

  add_index "signatures", ["petition_id", "member_id"], :name => "index_signatures_on_petition_id_and_member_id"

  create_table "social_media_trials", :force => true do |t|
    t.integer  "member_id"
    t.integer  "petition_id"
    t.string   "goal"
    t.string   "key"
    t.string   "choice"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "subscribes", :force => true do |t|
    t.integer  "member_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "subscribes", ["member_id"], :name => "index_subscribes_on_member_id"

  create_table "unsubscribes", :force => true do |t|
    t.string   "email",         :null => false
    t.string   "cause"
    t.integer  "member_id",     :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "ip_address"
    t.string   "user_agent"
    t.integer  "sent_email_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                              :null => false
    t.string   "password_digest",                    :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "is_super_user",   :default => false, :null => false
    t.boolean  "is_admin",        :default => false, :null => false
  end

  add_foreign_key "bounced_emails", "sent_emails", :name => "bounced_emails_sent_email_id_fk"

  add_foreign_key "petition_images", "petitions", :name => "petition_images_petition_id_fk"

  add_foreign_key "petition_titles", "petitions", :name => "petition_titles_petition_id_fk"

  add_foreign_key "petitions", "users", :name => "petitions_owner_id_fk", :column => "owner_id"

  add_foreign_key "sent_emails", "members", :name => "sent_emails_member_id_fk"
  add_foreign_key "sent_emails", "petitions", :name => "sent_emails_petition_id_fk"
  add_foreign_key "sent_emails", "signatures", :name => "sent_emails_signature_id_fk"

  add_foreign_key "signatures", "members", :name => "signatures_member_id_fk"
  add_foreign_key "signatures", "petitions", :name => "signatures_petition_id_fk"

  add_foreign_key "subscribes", "members", :name => "subscribes_member_id_fk"

  add_foreign_key "unsubscribes", "members", :name => "unsubscribes_member_id_fk"
  add_foreign_key "unsubscribes", "sent_emails", :name => "unsubscribes_sent_email_id_fk"

end
