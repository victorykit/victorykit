class AddReferringUrlToSignatures < ActiveRecord::Migration
  def change
    add_column :signatures, :referring_url, :text
  end
end
