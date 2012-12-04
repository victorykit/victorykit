class CreateUserFeedbacks < ActiveRecord::Migration
  def change
    create_table :user_feedbacks do |t|
      t.string :name
      t.string :email
      t.text :message

      t.timestamps
    end
  end
end
