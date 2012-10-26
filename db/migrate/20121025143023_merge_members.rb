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
        Member.where(id: rest).delete_all
      end
    end

    # seen.select {|email, count| count > 1}.each do |email, count|
    # end

    #     next if trash.include? m
    #     duplicates =  Member.order('id asc').
    #       find(:all, :conditions => ['lower(email)=?', m.email.downcase])
    #     first = duplicates.first
    #     rest = duplicates - [first]
    #     (rest.map(&:signatures).reduce(&:+) || []).each do |s|
    #       s.update_attributes(:member => first)
    #     end
    #     trash.concat rest
    #     rest.map{ |x|x.signatures=[]; }
    #     rest.map(&:destroy)
    #   end
    # end
  end

  def down
  end

end
