class AddIsLockedColumnToLastUpdatedUnsubscribes < ActiveRecord::Migration
  def change
    add_column :last_updated_unsubscribes, "is_locked", :boolean
  end
end
