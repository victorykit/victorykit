class DropCoreActionTable < ActiveRecord::Migration
  def change
  	drop_table :core_action
  end
end
