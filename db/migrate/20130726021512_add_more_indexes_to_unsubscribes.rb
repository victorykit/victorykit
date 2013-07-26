class AddMoreIndexesToUnsubscribes < ActiveRecord::Migration
  def change
    add_index :unsubscribes, [:member_id, :created_at]
  end
end
