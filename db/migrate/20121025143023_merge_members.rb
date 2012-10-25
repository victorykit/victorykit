class MergeMembers < ActiveRecord::Migration

  def up
    trash = []
    Member.all.each do |m|
      next if trash.include? m
      duplicates =  Member.order('id asc').
        find(:all, :conditions => ['lower(email)=?', m.email.downcase])
      first = duplicates.first
      rest = duplicates - [first]
      (rest.map(&:signatures).reduce(&:+) || []).each do |s|
        s.update_attributes(:member => first)
      end
      trash.concat rest
      rest.map{ |x|x.signatures=[]; }
      rest.map(&:destroy)
    end
  end

  def down
  end

end
