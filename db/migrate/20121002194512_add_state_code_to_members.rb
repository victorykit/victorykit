class AddStateCodeToMembers < ActiveRecord::Migration
  def change
    add_column :members, :state_code, :string
  end
end
