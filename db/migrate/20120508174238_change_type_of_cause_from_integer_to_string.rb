class ChangeTypeOfCauseFromIntegerToString < ActiveRecord::Migration
  def change
    change_column :unsubscribes, "cause", :string
  end
end
