require 'hasher'

class MemberHasher < Hasher

  def self.member_for(hashed_data)
    id = self.validate hashed_data
    return nil unless id
    return Member.where(:id => id).first
  end

  def self.generate data
    generate_with_prefix(data, 'm')
  end

  def self.validate hashed_data
    validate_with_prefix(hashed_data, 'm')
  end

end
