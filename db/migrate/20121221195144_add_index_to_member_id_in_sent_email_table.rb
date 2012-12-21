class AddIndexToMemberIdInSentEmailTable < ActiveRecord::Migration
  def change
    add_index :sent_emails, :member_id
  end
end
