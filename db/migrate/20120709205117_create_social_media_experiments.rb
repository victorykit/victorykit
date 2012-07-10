class CreateSocialMediaExperiments < ActiveRecord::Migration
  def change
    create_table :social_media_experiments do |t|
      t.integer :member_id
      t.integer :petition_id
      t.string :goal
      t.string :key
      t.string :choice

      t.timestamps
    end
  end
end
