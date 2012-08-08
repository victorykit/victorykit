require 'hasher'

class SentEmailHasher < Hasher

  def self.sent_email_for(hashed_data)
    id = self.validate(hashed_data)
    return nil unless id
    SentEmail.where(:id => id).first
  end

  def self.generate data
    # backward compatible
    generate_with_prefix(data, "")
  end

  def self.validate hashed_data
    validate_with_prefix(hashed_data, "")
  end


end
