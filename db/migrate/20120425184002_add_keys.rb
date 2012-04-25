class AddKeys < ActiveRecord::Migration
  def up
    add_foreign_key "petitions", "users", :name => "petitions_owner_id_fk", :column => "owner_id"
    add_foreign_key "signatures", "petitions", :name => "signatures_petition_id_fk"
  end
  def down
    remove_foreign_key "petitions", "users", :name => "petitions_owner_id_fk", :column => "owner_id"
    remove_foreign_key "signatures", "petitions", :name => "signatures_petition_id_fk"
  end
end
