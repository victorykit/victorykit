class SignatureTableMakeMemberIdPetitionIdUnique < ActiveRecord::Migration
  def change
    add_index :signatures, [:petition_id, :member_id]
  end
end
