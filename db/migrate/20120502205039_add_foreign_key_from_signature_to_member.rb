class AddForeignKeyFromSignatureToMember < ActiveRecord::Migration
  def change
    add_column :signatures, "member_id", :integer
    add_foreign_key "signatures", "members", :name => "signatures_member_id_fk", :column => "member_id"
  end
end
