class AddMemberships < ActiveRecord::Migration
  def change
    drop_table :subscribes

    create_table :memberships do |t|
      t.integer :member_id
      t.datetime :last_signed_at
      t.datetime :last_emailed_at
      t.timestamps
    end

    add_index :memberships, :member_id, unique: true
    add_index :memberships, [:created_at, :last_emailed_at]
  end
end
