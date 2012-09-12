class AddCreatedAtIndexToSignatures < ActiveRecord::Migration
  def change
    add_index :signatures, :created_at
  end
end
