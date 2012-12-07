class AddTypeToSentEmail < ActiveRecord::Migration
  def change
    add_column :sent_emails, :type, :string, default: 'SentEmail'    
  end
end
