class AddCreatedMemberIndexToSignatures < ActiveRecord::Migration
  def change
    add_index :signatures, [:created_member], algorithm: :concurrently
    add_index :sent_emails, [:type, :created_at], algorithm: :concurrently
  end
end
