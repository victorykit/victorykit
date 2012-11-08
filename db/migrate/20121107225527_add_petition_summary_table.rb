class AddPetitionSummaryTable < ActiveRecord::Migration
  def change
    create_table :petition_summaries do |t|
      t.text :short_summary, null: false
      t.integer :petition_id, null: false
      t.timestamps
    end

    add_foreign_key :petition_summaries, :petitions, :name => "petition_summaries_petition_id_fk", :column => "petition_id"
  end
end
