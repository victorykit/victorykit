class AddSentEmailClickedAtColumn < ActiveRecord::Migration
  def up
    change_table :sent_emails do |t|
      t.datetime :clicked_at
    end
  end

  def down
    remove_column :sent_emails, :clicked_at
  end
end
