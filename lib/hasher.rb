require 'base64'

class Hasher
  def self.generate(data)
    data.to_s + '.' + Base64.encode64(OpenSSL::HMAC.hexdigest('sha1', Settings.hasher.secret_key, data))[0..5]
  end

  def self.validate(hashed_data)
    number, hash = hashed_data.split(".")
    generate(number) == hashed_data
  end
end