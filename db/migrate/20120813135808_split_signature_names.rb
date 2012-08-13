class SplitSignatureNames < ActiveRecord::Migration
  def up
    add_column :signatures, :first_name, :string
    add_column :signatures, :last_name, :string
    Signature.reset_column_information
    Signature.all.each do |s|
      name_parts = s.name.split(" ")
      if name_parts.length == 1
        s.update_column :first_name, s.name
      else
        s.update_column :last_name, name_parts.pop
        s.update_column :first_name, name_parts.join(" ")
      end
    end
    remove_column :signatures, :name
  end

  def down
    add_column :signatures, :name, :string
    Signature.reset_column_information
    Signature.all.each do |s|
     s.update_column :name, "#{s.first_name} #{s.last_name}".strip
    end
    remove_column :signatures, :first_name
    remove_column :signatures, :last_name
  end
end
