class ActiveRecordWhiplashSession
  RESERVED = %w{ session_id tmp }

  delegate :[], :key?, :include?, :size, :each, to: :@session

  def initialize(opts={})
    @session_id    = opts[:session_id]
    @scope         = opts[:scope]
    @test_column   = opts[:test_column]
    @choice_column = opts[:choice_column]

    self.reload
  end

  def []=(test_name, choice)
    if !RESERVED.include?(test_name.to_s) && self[test_name] != choice
      record = if @session.key?(test_name)
        @scope.where(@test_column => test_name).first
      else
        @scope.build(@test_column => test_name, @choice_column => choice)
      end

      record.send "#{@choice_column}=", choice
      record.save
    end

    @session[ test_name ] = choice
  end

  def delete(test_name)
    if !RESERVED.include?(test_name.to_s)
      @scope.where(@test_column => test_name).destroy_all
    end

    @session.delete test_name
  end

  def reload
    data = @scope.map {|r| [ r.send(@test_column), r.send(@choice_column) ] }
    @session = Hash[ data ].merge session_id: @session_id

    self
  end

  def to_hash
    @session
  end

  alias_method :_inspect, :inspect

  def inspect; @session.inspect; end

end
