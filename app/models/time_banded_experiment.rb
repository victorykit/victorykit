class TimeBandedExperiment

  def initialize name, transitions
    @name = name
    @transitions = transitions
  end

  def name_as_of time
    name_per_transition = Hash[nil, @name].merge Hash[@transitions.map{|t| [t, "#{@name} (reset #{t.strftime('%Y-%m-%d %H:%M')})"]}]
    name_per_transition.inject(name_per_transition[nil]){|result, pair| (pair[0] and time and time >= pair[0]) ? pair[1] : result  }
  end

end