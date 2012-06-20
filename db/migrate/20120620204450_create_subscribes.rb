class CreateSubscribes < ActiveRecord::Migration
  def change
    create_table :subscribes do |t|
      t.references :member

      t.timestamps
    end
    add_index :subscribes, :member_id
  end
end
