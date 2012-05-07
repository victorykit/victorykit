class AddMailerWorkerTrackerAgain < ActiveRecord::Migration
  def change
    create_table :mailer_process_trackers do |t|
      t.boolean :is_locked
      
      t.timestamps
    end
  end
end
