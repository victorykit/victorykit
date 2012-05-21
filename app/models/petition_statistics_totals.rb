class PetitionStatisticsTotals
  def initialize(stats)
    @stats = stats
  end
  
  def hit_count
    sum(:hit_count)
  end
  
  def signature_count
    sum(:signature_count)
  end
  
  def new_member_count
    sum(:new_member_count)
  end
  
  def conversion_rate
    divide_safe(signature_count.to_f, hit_count.to_f)
  end
  
  def email_count
    sum(:email_count)
  end
  
  def email_signature_count
    sum(:email_signature_count)
  end
  
  def email_conversion_rate
    divide_safe(email_signature_count.to_f, email_count.to_f)
  end
  
  def virality_rate
    divide_safe(new_member_count.to_f, signature_count.to_f)
  end
  
  def sum method
    @stats.reduce(0){|sum, s| sum + s.send(method)}
  end
  
  def divide_safe(numerator, denominator)
    denominator.nonzero? ? numerator / denominator : 0
  end
end