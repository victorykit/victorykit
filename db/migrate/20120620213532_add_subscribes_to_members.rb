class AddSubscribesToMembers < ActiveRecord::Migration
  def change
    add_foreign_key :subscribes, :members, name: "subscribes_member_id_fk", column: "member_id"
  end
end
