class DeleteShortSummarryEmailExperiment < ActiveRecord::Migration
  def up
    EmailExperiment.delete_all("key = 'insert summary box to emails'")
  end

  def down
  end
end
