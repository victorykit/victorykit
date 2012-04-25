class AddRequiredConstraints < ActiveRecord::Migration
  def up
    change_table :petitions do | t |
      t.change :title, :string, null: false
      t.change :description, :string, null: false
    end
    change_table :signatures do | t |
      [:name, :email, :ip_address, :user_agent].each do |column|
        t.change column, :string, null: false
      end
      t.change :petition_id, :integer, null: false
    end
    change_table :users do | t |
      t.change :email, :string, null: false
      t.change :password_digest, :string, null: false
      t.change_default :is_super_user, false
      
      t.change :is_super_user, :boolean, null: false
    end
  end

  def down
    change_table :petitions do | t |
      t.change :title, :string, null: true
      t.change :description, :string, null: true
    end
    change_table :signatures do | t |
      [:name, :email, :ip_address, :user_agent].each do |column|
        t.change column, :string, null: true
      end
      t.change :petition_id, :integer, null: true
    end
    change_table :users do | t |
      t.change :email, :string, null: true
      t.change :password_digest, :string, null: true
      t.change_default :is_super_user, nil
      t.change :is_super_user, :boolean, null: true
    end
  end
end
