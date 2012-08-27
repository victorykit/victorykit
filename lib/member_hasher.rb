class MemberHasher < Hasher

  def self.generate data
    generate_with_prefix(data, 'm')
  end

  def self.validate hashed_data
    validate_with_prefix(hashed_data, 'm')
  end

end
