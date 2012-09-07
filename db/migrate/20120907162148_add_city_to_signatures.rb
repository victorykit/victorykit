class AddCityToSignatures < ActiveRecord::Migration
  def change
    add_column :signatures, :city, :string
  end
end
