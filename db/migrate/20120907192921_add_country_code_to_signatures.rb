class AddCountryCodeToSignatures < ActiveRecord::Migration
  def change
    add_column :signatures, :country_code, :string
  end
end
