class AddHttpRefererToSignature < ActiveRecord::Migration
  def change
    add_column :signatures, :http_referer, :string
  end
end
