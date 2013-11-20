class AddFullnameToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.column :fullname, :string
    end
  end

  def down
    change_table :users do |t|
      t.remove :fullname, :string
    end
  end
end
