# One-off, to remove in a future commit.
namespace :script do
  task :migrate_referral_codes => :env do
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
end