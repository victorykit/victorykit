require 'hasher'

class SentEmailHasher < Hasher

  def self.member_for(hashed_data)
    SentEmail.where(:id => self.validate(hashed_data)).first
  end

  def self.generate data
    # backward compatible
    generate_with_prefix(data, "")
  end

  def self.validate hashed_data
    validate_with_prefix(hashed_data, "")
  end


end
