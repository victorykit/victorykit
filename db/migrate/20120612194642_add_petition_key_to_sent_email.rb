class AddPetitionKeyToSentEmail < ActiveRecord::Migration
  def change
    add_foreign_key :sent_emails, :petitions, name: "sent_emails_petition_id_fk", column: "petition_id"
  end
end