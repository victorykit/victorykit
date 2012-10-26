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
        Signature.where(member_id: rest).update_all(member_id: first)
        SentEmail.where(member_id: rest).update_all(member_id: first)
        Member.where(id: rest).delete_all
      end
    end
  end

  def down
  end

end
