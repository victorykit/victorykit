class CrmStates < ActiveRecord::Migration
  def up
    create_table :crm_states do |t|
      t.string    :key
      t.string    :value
      t.timestamp :ts_value
      t.timestamps
    end
    add_index :crm_states, :key
  end

  def down
  	drop_table :crm_states
  end
end
