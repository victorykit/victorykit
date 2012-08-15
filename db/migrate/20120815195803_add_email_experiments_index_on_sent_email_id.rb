class AddEmailExperimentsIndexOnSentEmailId < ActiveRecord::Migration
  def up
    add_index :email_experiments, :sent_email_id
  end

  def down
    remove_index :email_experiments, :sent_email_id
  end
end
