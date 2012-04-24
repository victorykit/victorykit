class AddSuperUserFlagToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_super_user, :boolean
  end
end
