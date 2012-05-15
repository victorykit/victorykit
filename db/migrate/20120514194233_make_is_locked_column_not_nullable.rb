class MakeIsLockedColumnNotNullable < ActiveRecord::Migration
  def change
    change_table :last_updated_unsubscribes do | t |
      t.change :is_locked, :boolean, null: false
    end
  end
end
