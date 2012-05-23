class PetitionStatisticsTotals
  def initialize(stats)
    @stats = stats
  end

  def method_missing method
    @stats.reduce(0){|sum, s| sum + s.send(method)}
  end
end
