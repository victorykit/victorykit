class AddUnsubscribeTable < ActiveRecord::Migration
  def change
    create_table :unsubscribes do |t|
      t.string :email, null: false
      t.integer :cause
      t.integer :member_id, null: false
      t.timestamps
    end
    
    add_foreign_key :unsubscribes, :members, name: "unsubscribes_member_id_fk", column: "member_id"
  end
end
