class AddReferringEmailToUnsubscribes < ActiveRecord::Migration
  def change
    add_column :unsubscribes, "sent_email_id", :integer
    add_foreign_key :unsubscribes, :sent_emails, name: "unsubscribes_sent_email_id_fk", column: "sent_email_id"
  end
end
