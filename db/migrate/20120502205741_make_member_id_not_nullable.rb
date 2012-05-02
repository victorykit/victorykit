class MakeMemberIdNotNullable < ActiveRecord::Migration
  def change
    change_table :signatures do | t |
      t.change :member_id, :integer, null: false
    end
  end
end
