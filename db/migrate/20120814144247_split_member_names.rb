class SplitMemberNames < ActiveRecord::Migration
  def up
    add_column :members, :first_name, :string
    add_column :members, :last_name, :string
    Member.reset_column_information
    Member.all.each do |m|
      name_parts = m.name.split(" ")
      if name_parts.length == 1
        m.update_column :first_name, m.name
      else
        m.update_column :last_name, name_parts.pop
        m.update_column :first_name, name_parts.join(" ")
      end
    end
    remove_column :members, :name
  end

  def down
    add_column :members, :name, :string
    Member.reset_column_information
    Member.all.each do |m|
     m.update_column :name, "#{m.first_name} #{m.last_name}".strip
    end
    remove_column :members, :first_name
    remove_column :members, :last_name
  end
end
