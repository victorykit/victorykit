class AddSentEmailIdToBouncedEmail < ActiveRecord::Migration
  def change
    add_column :bounced_emails, :sent_email_id, :integer, null: false
    add_foreign_key :bounced_emails, :sent_emails, name: "bounced_emails_sent_email_id_fk", column: "sent_email_id"
  end
end
