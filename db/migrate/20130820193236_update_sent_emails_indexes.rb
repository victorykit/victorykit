class UpdateSentEmailsIndexes < ActiveRecord::Migration
  def up
    add_index :sent_emails, [:created_at, :type], algorithm: :concurrently

    #   Using raw sql for 'IF EXISTS'
    execute 'DROP INDEX IF EXISTS index_sent_emails_on_type_and_created_at'
    execute 'DROP INDEX IF EXISTS index_sent_emails_on_created_at'

    # These indexes exist on production and duplicate other indexes
    execute 'DROP INDEX IF EXISTS sent_emails_member_id_idx'
    execute 'DROP INDEX IF EXISTS sent_emails_created_idx'
  end

  def down
    add_index :sent_emails, [:type, :created_at], algorithm: :concurrently
    add_index :sent_emails, [:created_at], algorithm: :concurrently
    #   Using raw sql for 'IF EXISTS'
    execute 'DROP INDEX IF EXISTS index_sent_emails_on_created_at_and_type'
  end
end
