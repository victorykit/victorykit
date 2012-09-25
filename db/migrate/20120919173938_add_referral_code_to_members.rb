class AddReferralCodeToMembers < ActiveRecord::Migration

  class Member < ActiveRecord::Base
    def to_hash
      # Intentionally duplicated from MemberHasher and Hasher so as not to break future migrations.
      data = self.id
      prefix = 'm'
      data.to_s + '.' + Base64.urlsafe_encode64(OpenSSL::HMAC.digest('sha1', Settings.hasher.secret_key, prefix.to_s + data.to_s))[0..5]
    end
  end

  def up
    add_column :members, :referral_code, :string
    add_index :members, :referral_code
    add_column :social_media_trials, :referral_code, :string
    add_index :social_media_trials, :referral_code
    # In a future migration: remove_column :social_media_trials, :member_id

    Member.find_in_batches(batch_size: 1000) do |group|
      group.each { |m| m.update_column(:referral_code, m.to_hash) }
    end

    execute <<-SQL
      UPDATE social_media_trials
      SET referral_code = members.referral_code
      FROM members
      WHERE social_media_trials.member_id = members.id
    SQL
  end

  def down
    remove_column :members, :referral_code
    remove_index :members, :referral_code
    remove_column :social_media_trials, :referral_code
    remove_index :social_media_trials, :referral_code
  end
end
