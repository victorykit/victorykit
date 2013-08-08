class AddHstoreSettingsToApp < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION IF NOT EXISTS hstore;"

    create_table :settings do |t|
      t.hstore :data
      t.timestamps
    end
  end

  def down
    drop_table :settings
  end
end
