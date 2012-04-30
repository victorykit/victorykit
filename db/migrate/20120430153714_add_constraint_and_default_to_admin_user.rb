class AddConstraintAndDefaultToAdminUser < ActiveRecord::Migration
  def change
    change_table :users do | t |
      t.change :is_admin, :boolean, null: false, :default => false
    end
  end
end
