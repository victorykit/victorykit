class Hasher
  def self.generate(data)
    key = 'victorize'
    data.to_s + '.' + OpenSSL::HMAC.digest('sha1', key, data)
  end

  def self.validate(hashed_data)
    number, hash = hashed_data.split(".")
    generate(number) == hashed_data
  end
end