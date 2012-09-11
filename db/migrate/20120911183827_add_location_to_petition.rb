class AddLocationToPetition < ActiveRecord::Migration
  def change
    add_column :petitions, :location, :string
  end
end
