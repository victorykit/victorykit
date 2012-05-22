class AddSentEmailWasOpenedColumn < ActiveRecord::Migration
  def up
    change_table :sent_emails do |t|
      t.boolean :was_opened, :default => false
    end
  end

  def down
    remove_column :sent_emails, :was_opened
  end
end
