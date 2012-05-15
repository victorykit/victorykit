class CreateLastUpdatedUnsubscribes < ActiveRecord::Migration
  def change
    create_table :last_updated_unsubscribes do |t|

      t.timestamps
    end
  end
end
