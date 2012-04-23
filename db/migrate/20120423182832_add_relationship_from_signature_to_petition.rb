class AddRelationshipFromSignatureToPetition < ActiveRecord::Migration
  def change
    change_table :signatures do |t|
      t.integer :petition_id
    end
  end
end
