class AddSignatureIdToEmailSent < ActiveRecord::Migration
  def change
    add_column :sent_emails, "signature_id", :integer
    add_foreign_key "sent_emails", "signatures", :name => "sent_emails_signature_id_fk", :column => "signature_id"
  end
end
