class AddTypeToSentEmail < ActiveRecord::Migration
  def change
    add_column :sent_emails, :type, :string
    execute "UPDATE sent_emails SET type = 'ScheduledSentEmail'"
  end
end
