class AddExistsFlagToSignature < ActiveRecord::Migration
  def change
    add_column :signatures, :created_member, :boolean
  end
end
