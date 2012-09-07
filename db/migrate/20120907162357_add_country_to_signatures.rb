class AddCountryToSignatures < ActiveRecord::Migration
  def change
    add_column :signatures, :country, :string
  end
end
