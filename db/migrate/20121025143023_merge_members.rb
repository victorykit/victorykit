class MergeMembers < ActiveRecord::Migration

  def up
    seen = {}

    Member.find_in_batches do |batch|
      batch.each do |m|
        email = m.email.downcase
        seen[email] ||= []
        seen[email] << m.id
      end
    end

    seen.each do |email, ids|
      if ids.size > 1
        first, rest = ids[0], ids[1..-1]
        [Signature, SentEmail, Unsubscribe, FacebookFriend, EmailError].each do |collection|
          collection.where(member_id: rest).update_all(member_id: first)
        end
        Member.where(id: rest).delete_all
      end
    end
  end

  def down
  end

end
