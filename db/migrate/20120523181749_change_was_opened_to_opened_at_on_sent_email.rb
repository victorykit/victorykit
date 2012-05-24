class ChangeWasOpenedToOpenedAtOnSentEmail < ActiveRecord::Migration

  def change
    add_column :sent_emails, :opened_at, :datetime
    remove_column :sent_emails, :was_opened
  end  

  def down
    remove_column :sent_emails, :opened_at, :datetime
    add_column :sent_emails, :was_opened, :default => false
  end

end
