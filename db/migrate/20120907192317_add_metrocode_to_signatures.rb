class AddMetrocodeToSignatures < ActiveRecord::Migration
  def change
    add_column :signatures, :metrocode, :string
  end
end
