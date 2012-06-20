class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :member
      t.references :petition

      t.timestamps
    end
    add_index :likes, :member_id
    add_index :likes, :petition_id
  end
end
