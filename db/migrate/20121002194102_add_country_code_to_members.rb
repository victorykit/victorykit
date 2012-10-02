class AddCountryCodeToMembers < ActiveRecord::Migration
  def change
    add_column :members, :country_code, :string
  end
end
