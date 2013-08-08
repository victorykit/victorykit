class AddHstoreSettingsToApp < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.hstore :data
      t.timestamps
    end
  end
end
