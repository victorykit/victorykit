class AddDeviseToUsers < ActiveRecord::Migration
  def self.up

    execute 'ALTER TABLE users rename password_digest TO encrypted_password'
    change_table(:users, :bulk => true) do |t|
      ## Database authenticatable
      t.change_default :email, ""
      t.change_default :encrypted_password, ""
      #t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      ## Token authenticatable
      # t.string :authentication_token


      # Uncomment below if timestamps were not included in your original model.
      # t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true

    # add_index :users, :confirmation_token,   :unique => true
    add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.

    execute 'ALTER TABLE users rename encrypted_password to password_digest'
    change_table(:users, :bulk => true) do |t|

      t.change_default :email, nil
      t.change_default :password_digest, nil

      ## Recoverable
      t.remove :reset_password_token
      t.remove :reset_password_sent_at

      ## Rememberable
      t.remove :remember_created_at

      ## Trackable
      t.remove :sign_in_count
      t.remove :current_sign_in_at
      t.remove :last_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_ip

      ## Confirmable
      # t.remove :confirmation_token
      # t.remove :confirmed_at
      # t.remove :confirmation_sent_at
      # t.remove :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.remove :failed_attempts
      t.remove :unlock_token
      t.remove :locked_at

      ## Token authenticatable
      # t.remove :authentication_token

      # Uncomment below if timestamps were not included in your original model.
      # t.timestamps
    end

    # Want to keep this index as it should have existed in the first place!
    # remove_index :users, :email

  end
end
