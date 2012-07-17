class AllowNullSentEmailInBouncedEmail < ActiveRecord::Migration
  def up
    change_column :bounced_emails, :sent_email_id, :integer, :null => true
  end

  def down
    change_column :bounced_emails, :sent_email_id, :integer, :null => false
  end
end
