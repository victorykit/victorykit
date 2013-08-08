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
      self.instance.data[key]
    end

    def []=(key, value)
      self.instance.data[key] = value
      self.instance.save
      value
    end

  end
end
