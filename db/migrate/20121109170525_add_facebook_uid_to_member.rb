class AddFacebookUidToMember < ActiveRecord::Migration
  def change
    add_column :members, :facebook_uid, :integer, {limit: 8} #facebook uids are big ints
  end
end
