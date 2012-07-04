require 'base64'

class Hasher
  def self.generate_with_prefix(data, prefix)
    data.to_s + '.' + Base64.urlsafe_encode64(OpenSSL::HMAC.digest('sha1', Settings.hasher.secret_key, prefix.to_s + data.to_s))[0..5] if data.present?
  end

  def self.validate_with_prefix(hashed_data, prefix)
    if hashed_data.nil?
      return false
    end
    number, hash = hashed_data.split(".")

    if generate_with_prefix(number, prefix) == hashed_data
      return number.to_i
    else
      return false
    end
  end

  private_class_method :generate_with_prefix, :validate_with_prefix
end
