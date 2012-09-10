class AddStateToSignatures < ActiveRecord::Migration
  def change
    add_column :signatures, :state, :string
  end
end
