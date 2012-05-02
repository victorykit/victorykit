class AddEmailSentTable < ActiveRecord::Migration
  def change
    create_table :sent_emails do |t|
      t.string :email, null: false
      t.integer :member_id, null: false
      t.integer :petition_id, null: false
      t.timestamps
    end
    
    add_foreign_key :sent_emails, :members, name: "sent_emails_member_id_fk", column: "member_id"
  end
end
