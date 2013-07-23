class AddIndexesToUnsubscribes < ActiveRecord::Migration
  def change
    add_index :unsubscribes, [:sent_email_id]
  end
end
