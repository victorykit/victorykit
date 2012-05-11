class AddBouncedEmailsTable < ActiveRecord::Migration
  def change
    create_table :bounced_emails do |t|
      t.text :raw_content, :limit => nil
      t.timestamps
    end
  end
end
