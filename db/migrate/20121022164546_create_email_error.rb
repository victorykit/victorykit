class CreateEmailError < ActiveRecord::Migration
  def change
    create_table :email_errors do |t|

      t.integer :member_id, null: false
      t.string :email
      t.text :error
      
      t.timestamps
    end

    add_foreign_key :email_errors, :members, :name => "email_errors_member_id_fk", :column => "member_id"
  end
end
