class AppSettings < ActiveRecord::Base
  serialize :data, ActiveRecord::Coders::Hstore
  self.table_name = "settings"

  class << self

    def instance
      @instance ||= ( self.first || self.create )
    end

    def create_with_instance_checking(*args)
      if self.first.nil?
        create_without_instance_checking(*args)
      else
        raise "Can't create a new instance."
      end
    end

    alias_method_chain :create, :instance_checking

    def [](key)
      self.instance.data[key.to_s]
    end

    def []=(key, value)
      self.instance.data[key.to_s] = value
      self.instance.save
      value
    end

    def merge(hash={})
      self.instance.data.merge! hash
      self.instance.save
      self.instance.data
    end

    def has_key?(key)
      self.instance.data.has_key?(key.to_s)
    end

    # Returns a single or array for destructuring, or raises if any keys unavailable.
    def require_keys!(*keys)
      vals = self.instance.data.values_at(*keys).tap do |values|
        raise "Require app settings: #{keys.join(', ')}" if values.any? &:nil?
      end

      vals.length == 1 ? vals[0] : vals
    end

  end
end
