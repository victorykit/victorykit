require 'hasher'

class SignatureHasher < Hasher

  def self.generate data
    generate_with_prefix(data, "s")
  end

  def self.validate hashed_data
    validate_with_prefix(hashed_data, "s")
  end
end
