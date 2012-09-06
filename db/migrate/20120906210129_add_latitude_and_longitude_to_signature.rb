class AddLatitudeAndLongitudeToSignature < ActiveRecord::Migration
  def change
    add_column :signatures, :latitude, :float
    add_column :signatures, :longitude, :float
  end
end
