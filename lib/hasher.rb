require 'base64'

class Hasher
  def self.generate(data)
    URI.escape(data.to_s + '.' + Base64.encode64(OpenSSL::HMAC.digest('sha1', Settings.hasher.secret_key, data.to_s))[0..5])
  end

  def self.validate(hashed_data)
    if hashed_data.nil?
      return false
    end
    number, hash = URI.unescape(hashed_data).split(".")

    if generate(number) == hashed_data
      return number.to_i
    else
      puts "generated #{generate(number)}"
      puts "vs #{hashed_data}"
      puts "with key #{Settings.hasher.secret_key}"
      return false
    end
  end
end