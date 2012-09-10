class AddStateCodeToSignatures < ActiveRecord::Migration
  def change
    add_column :signatures, :state_code, :string
  end
end
