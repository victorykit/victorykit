class AddStoredToPetitionImages < ActiveRecord::Migration
  def change
    add_column :petition_images, :stored, :boolean
  end
end
