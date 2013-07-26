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

ActiveRecord::Schema.define(:version => 20130726021512) do

  create_table "bounced_emails", :force => true do |t|
    t.text     "raw_content"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "sent_email_id"
  end

  create_table "donations", :force => true do |t|
    t.integer  "petition_id"
    t.integer  "member_id"
    t.integer  "referral_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.float    "amount"
  end

  create_table "email_errors", :force => true do |t|
    t.integer  "member_id",  :null => false
    t.string   "email"
    t.text     "error"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "email_experiments", :force => true do |t|
    t.integer  "sent_email_id"
    t.string   "goal"
    t.string   "key"
    t.string   "choice"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "email_experiments", ["sent_email_id"], :name => "index_email_experiments_on_sent_email_id"

  create_table "facebook_actions", :force => true do |t|
    t.integer  "member_id"
    t.integer  "petition_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "type"
    t.string   "action_id"
  end

  add_index "facebook_actions", ["action_id"], :name => "index_facebook_actions_action_id"
  add_index "facebook_actions", ["member_id"], :name => "index_likes_on_member_id"
  add_index "facebook_actions", ["petition_id"], :name => "index_likes_on_petition_id"

  create_table "facebook_friends", :force => true do |t|
    t.integer  "member_id",   :null => false
    t.string   "facebook_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "facebook_friends", ["member_id", "facebook_id"], :name => "unique_facebook_friend", :unique => true

  create_table "facebook_share_widget_shares", :force => true do |t|
    t.string   "user_facebook_id"
    t.string   "friend_facebook_id"
    t.string   "url"
    t.text     "message"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "facebook_share_widget_shares", ["user_facebook_id", "friend_facebook_id", "url"], :name => "unique_share", :unique => true

  create_table "ip_locations", :id => false, :force => true do |t|
    t.integer "ip_from",      :limit => 8
    t.integer "ip_to",        :limit => 8
    t.string  "country_code", :limit => 2
    t.text    "country_name"
    t.text    "region"
    t.text    "city"
    t.string  "state_code",   :limit => 2
  end

  create_table "last_updated_unsubscribes", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "is_locked",  :null => false
  end

  create_table "mailer_process_trackers", :force => true do |t|
    t.boolean  "is_locked"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "uuid"
  end

  create_table "members", :force => true do |t|
    t.string   "email"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "referral_code"
    t.string   "country_code"
    t.string   "state_code"
    t.boolean  "null_last_name"
    t.boolean  "blank_last_name"
    t.boolean  "blank_first_name"
    t.integer  "facebook_uid",     :limit => 8
  end

  add_index "members", ["email"], :name => "index_members_on_email", :unique => true
  add_index "members", ["referral_code"], :name => "index_members_on_referral_code"

  create_table "petition_descriptions", :force => true do |t|
    t.text     "facebook_description", :null => false
    t.integer  "petition_id",          :null => false
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "petition_images", :force => true do |t|
    t.text     "url",         :null => false
    t.integer  "petition_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.boolean  "stored"
  end

  create_table "petition_reports", :force => true do |t|
    t.integer  "petition_id"
    t.text     "petition_title"
    t.datetime "petition_created_at"
    t.integer  "sent_emails_count_day"
    t.integer  "signatures_count_day"
    t.integer  "opened_emails_count_day"
    t.integer  "clicked_emails_count_day"
    t.integer  "signed_from_emails_count_day"
    t.integer  "new_members_count_day"
    t.integer  "unsubscribes_count_day"
    t.integer  "like_count_day"
    t.integer  "hit_count_day"
    t.float    "opened_emails_rate_day"
    t.float    "clicked_emails_rate_day"
    t.float    "signed_from_emails_rate_day"
    t.float    "new_members_rate_day"
    t.float    "unsubscribes_rate_day"
    t.float    "like_rate_day"
    t.float    "hit_rate_day"
    t.integer  "sent_emails_count_week"
    t.integer  "signatures_count_week"
    t.integer  "opened_emails_count_week"
    t.integer  "clicked_emails_count_week"
    t.integer  "signed_from_emails_count_week"
    t.integer  "new_members_count_week"
    t.integer  "unsubscribes_count_week"
    t.integer  "like_count_week"
    t.integer  "hit_count_week"
    t.float    "opened_emails_rate_week"
    t.float    "clicked_emails_rate_week"
    t.float    "signed_from_emails_rate_week"
    t.float    "new_members_rate_week"
    t.float    "unsubscribes_rate_week"
    t.float    "like_rate_week"
    t.float    "hit_rate_week"
    t.integer  "sent_emails_count_month"
    t.integer  "signatures_count_month"
    t.integer  "opened_emails_count_month"
    t.integer  "clicked_emails_count_month"
    t.integer  "signed_from_emails_count_month"
    t.integer  "new_members_count_month"
    t.integer  "unsubscribes_count_month"
    t.integer  "like_count_month"
    t.integer  "hit_count_month"
    t.float    "opened_emails_rate_month"
    t.float    "clicked_emails_rate_month"
    t.float    "signed_from_emails_rate_month"
    t.float    "new_members_rate_month"
    t.float    "unsubscribes_rate_month"
    t.float    "like_rate_month"
    t.float    "hit_rate_month"
    t.integer  "sent_emails_count_year"
    t.integer  "signatures_count_year"
    t.integer  "opened_emails_count_year"
    t.integer  "clicked_emails_count_year"
    t.integer  "signed_from_emails_count_year"
    t.integer  "new_members_count_year"
    t.integer  "unsubscribes_count_year"
    t.integer  "like_count_year"
    t.integer  "hit_count_year"
    t.float    "opened_emails_rate_year"
    t.float    "clicked_emails_rate_year"
    t.float    "signed_from_emails_rate_year"
    t.float    "new_members_rate_year"
    t.float    "unsubscribes_rate_year"
    t.float    "like_rate_year"
    t.float    "hit_rate_year"
  end

  add_index "petition_reports", ["clicked_emails_rate_day"], :name => "index_petition_reports_on_clicked_emails_rate_day"
  add_index "petition_reports", ["clicked_emails_rate_month"], :name => "index_petition_reports_on_clicked_emails_rate_month"
  add_index "petition_reports", ["clicked_emails_rate_week"], :name => "index_petition_reports_on_clicked_emails_rate_week"
  add_index "petition_reports", ["clicked_emails_rate_year"], :name => "index_petition_reports_on_clicked_emails_rate_year"
  add_index "petition_reports", ["hit_rate_day"], :name => "index_petition_reports_on_hit_rate_day"
  add_index "petition_reports", ["hit_rate_month"], :name => "index_petition_reports_on_hit_rate_month"
  add_index "petition_reports", ["hit_rate_week"], :name => "index_petition_reports_on_hit_rate_week"
  add_index "petition_reports", ["hit_rate_year"], :name => "index_petition_reports_on_hit_rate_year"
  add_index "petition_reports", ["like_rate_day"], :name => "index_petition_reports_on_like_rate_day"
  add_index "petition_reports", ["like_rate_month"], :name => "index_petition_reports_on_like_rate_month"
  add_index "petition_reports", ["like_rate_week"], :name => "index_petition_reports_on_like_rate_week"
  add_index "petition_reports", ["like_rate_year"], :name => "index_petition_reports_on_like_rate_year"
  add_index "petition_reports", ["new_members_rate_day"], :name => "index_petition_reports_on_new_members_rate_day"
  add_index "petition_reports", ["new_members_rate_month"], :name => "index_petition_reports_on_new_members_rate_month"
  add_index "petition_reports", ["new_members_rate_week"], :name => "index_petition_reports_on_new_members_rate_week"
  add_index "petition_reports", ["new_members_rate_year"], :name => "index_petition_reports_on_new_members_rate_year"
  add_index "petition_reports", ["opened_emails_rate_day"], :name => "index_petition_reports_on_opened_emails_rate_day"
  add_index "petition_reports", ["opened_emails_rate_month"], :name => "index_petition_reports_on_opened_emails_rate_month"
  add_index "petition_reports", ["opened_emails_rate_week"], :name => "index_petition_reports_on_opened_emails_rate_week"
  add_index "petition_reports", ["opened_emails_rate_year"], :name => "index_petition_reports_on_opened_emails_rate_year"
  add_index "petition_reports", ["petition_created_at"], :name => "index_petition_reports_on_petition_created_at"
  add_index "petition_reports", ["petition_id"], :name => "index_petition_reports_on_petition_id"
  add_index "petition_reports", ["petition_title"], :name => "index_petition_reports_on_petition_title"
  add_index "petition_reports", ["sent_emails_count_day"], :name => "index_petition_reports_on_sent_emails_count_day"
  add_index "petition_reports", ["sent_emails_count_month"], :name => "index_petition_reports_on_sent_emails_count_month"
  add_index "petition_reports", ["sent_emails_count_week"], :name => "index_petition_reports_on_sent_emails_count_week"
  add_index "petition_reports", ["sent_emails_count_year"], :name => "index_petition_reports_on_sent_emails_count_year"
  add_index "petition_reports", ["signed_from_emails_rate_day"], :name => "index_petition_reports_on_signed_from_emails_rate_day"
  add_index "petition_reports", ["signed_from_emails_rate_month"], :name => "index_petition_reports_on_signed_from_emails_rate_month"
  add_index "petition_reports", ["signed_from_emails_rate_week"], :name => "index_petition_reports_on_signed_from_emails_rate_week"
  add_index "petition_reports", ["signed_from_emails_rate_year"], :name => "index_petition_reports_on_signed_from_emails_rate_year"
  add_index "petition_reports", ["unsubscribes_rate_day"], :name => "index_petition_reports_on_unsubscribes_rate_day"
  add_index "petition_reports", ["unsubscribes_rate_month"], :name => "index_petition_reports_on_unsubscribes_rate_month"
  add_index "petition_reports", ["unsubscribes_rate_week"], :name => "index_petition_reports_on_unsubscribes_rate_week"
  add_index "petition_reports", ["unsubscribes_rate_year"], :name => "index_petition_reports_on_unsubscribes_rate_year"

  create_table "petition_summaries", :force => true do |t|
    t.text     "short_summary", :null => false
    t.integer  "petition_id",   :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "petition_titles", :force => true do |t|
    t.text     "title",       :null => false
    t.string   "title_type",  :null => false
    t.integer  "petition_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "petition_versions", :force => true do |t|
    t.text     "title"
    t.text     "description"
    t.integer  "petition_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "petitions", :force => true do |t|
    t.text     "title",                          :null => false
    t.text     "description",                    :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "owner_id"
    t.boolean  "to_send",     :default => false
    t.string   "ip_address"
    t.string   "location"
    t.boolean  "deleted"
    t.datetime "featured_on"
  end

  add_index "petitions", ["title"], :name => "index_petitions_on_title"

  create_table "referrals", :force => true do |t|
    t.string   "code"
    t.integer  "member_id"
    t.integer  "petition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "referrals", ["code"], :name => "index_referral_codes_on_code"
  add_index "referrals", ["member_id"], :name => "index_referral_codes_on_member_id"

  create_table "sent_emails", :force => true do |t|
    t.string   "email",                                 :null => false
    t.integer  "member_id",                             :null => false
    t.integer  "petition_id",                           :null => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "signature_id"
    t.datetime "clicked_at"
    t.datetime "opened_at"
    t.string   "type",         :default => "SentEmail"
  end

  add_index "sent_emails", ["clicked_at"], :name => "index_sent_emails_on_clicked_at"
  add_index "sent_emails", ["created_at"], :name => "index_sent_emails_on_created_at"
  add_index "sent_emails", ["created_at"], :name => "sent_emails_created_idx"
  add_index "sent_emails", ["member_id"], :name => "index_sent_emails_on_member_id"
  add_index "sent_emails", ["member_id"], :name => "sent_emails_member_id_idx"
  add_index "sent_emails", ["opened_at"], :name => "index_sent_emails_on_opened_at"
  add_index "sent_emails", ["petition_id"], :name => "index_sent_emails_on_petition_id"
  add_index "sent_emails", ["signature_id"], :name => "index_sent_emails_on_signature_id"

  create_table "signatures", :force => true do |t|
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
    t.string   "first_name"
    t.string   "last_name"
    t.string   "city"
    t.string   "metrocode"
    t.string   "state"
    t.string   "state_code"
    t.string   "country_code"
    t.text     "http_referer"
  end

  add_index "signatures", ["created_at"], :name => "index_signatures_on_created_at"
  add_index "signatures", ["petition_id", "member_id"], :name => "index_signatures_on_petition_id_and_member_id"
  add_index "signatures", ["referer_id", "petition_id"], :name => "index_signatures_on_referer_id_and_petition_id"

  create_table "social_media_trials", :force => true do |t|
    t.integer  "member_id"
    t.integer  "petition_id"
    t.string   "goal"
    t.string   "key"
    t.string   "choice"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "referral_code"
    t.integer  "referral_id"
  end

  add_index "social_media_trials", ["referral_code"], :name => "index_social_media_trials_on_referral_code"
  add_index "social_media_trials", ["referral_id"], :name => "index_social_media_trials_on_referral_code_id"

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

  add_index "unsubscribes", ["member_id", "created_at"], :name => "index_unsubscribes_on_member_id_and_created_at"
  add_index "unsubscribes", ["sent_email_id"], :name => "index_unsubscribes_on_sent_email_id"

  create_table "user_feedbacks", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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

  add_foreign_key "email_errors", "members", :name => "email_errors_member_id_fk"

  add_foreign_key "facebook_friends", "members", :name => "facebook_friends_member_id_fk"

  add_foreign_key "petition_descriptions", "petitions", :name => "petition_descriptions_petition_id_fk"

  add_foreign_key "petition_images", "petitions", :name => "petition_images_petition_id_fk"

  add_foreign_key "petition_summaries", "petitions", :name => "petition_summaries_petition_id_fk"

  add_foreign_key "petition_titles", "petitions", :name => "petition_titles_petition_id_fk"

  add_foreign_key "petition_versions", "petitions", :name => "petition_versions_petition_id_fk"

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
