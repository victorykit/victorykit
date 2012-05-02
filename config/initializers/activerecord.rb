module ActiveRecord
  class Base
    def self.random
      if (c = count) != 0
        find(:first, :offset =>rand(c))
      end
    end
  end
end
