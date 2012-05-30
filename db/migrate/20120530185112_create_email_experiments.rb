class CreateEmailExperiments < ActiveRecord::Migration
  def change
    create_table :email_experiments do |t|
      t.integer :sent_email_id
      t.string :goal
      t.string :key
      t.string :choice

      t.timestamps
    end
  end
end
