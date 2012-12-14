class AddFeaturedOnDateToPetition < ActiveRecord::Migration
  def change
    add_column :petitions, :featured_on, :datetime
  end
end
