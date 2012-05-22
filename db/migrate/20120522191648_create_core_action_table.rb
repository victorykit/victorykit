class CreateCoreActionTable < ActiveRecord::Migration
  def change
    create_table :core_action do |t|
      t.string :email
      t.integer :user_id
      t.timestamps
    end
  end
end
