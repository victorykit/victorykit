class AddIndexToRefererIdInSignatureTable < ActiveRecord::Migration
  def change
    add_index :signatures, :referer_id
  end
end
