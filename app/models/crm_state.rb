class CrmState < ActiveRecord::Base

  def self.[](key)
    v = CrmState.find_by_key(key)

    if v
      v.value || v.ts_value
    else
      nil
    end
  end

  def self.[]=(key, value)
    cs = CrmState.find_by_key(key)
    if value
      if cs.nil?
        cs = CrmState.new
        cs.key = key
      end
      if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include?(value.class)
        cs.ts_value = value
        cs.value    = nil
      else
        cs.value    = value
        cs.ts_value = nil
      end
      cs.save!
    else
      cs.destroy if cs
      nil
    end
  end

end