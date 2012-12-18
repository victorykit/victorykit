class AddIndexesToSentEmailsAndPetitions < ActiveRecord::Migration
  def change
    add_index(:sent_emails, :petition_id)
    add_index(:sent_emails, :opened_at)
    add_index(:sent_emails, :clicked_at)
    add_index(:sent_emails, :signature_id)
    add_index(:petitions,   :title)
  end
end
