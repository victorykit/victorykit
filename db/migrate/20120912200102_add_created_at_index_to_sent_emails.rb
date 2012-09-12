class AddCreatedAtIndexToSentEmails < ActiveRecord::Migration
  def change
    add_index :sent_emails, :created_at
  end
end
