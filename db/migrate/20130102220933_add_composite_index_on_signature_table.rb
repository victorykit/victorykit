class AddCompositeIndexOnSignatureTable < ActiveRecord::Migration
  def change
    remove_index :signatures, :referer_id

    add_index "signatures", ["referer_id", "petition_id"], :name => "index_signatures_on_referer_id_and_petition_id"
  end
end
