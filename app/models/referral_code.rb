class ReferralCode < ActiveRecord::Base
  include Whiplash
  attr_accessible :code, :member_id, :petition_id, :member, :petition

  belongs_to :member
  belongs_to :petition

  has_many :social_media_trials
  validates :code, uniqueness: true
  validates :member_id, :petition_id, presence: true

  after_initialize :generate_code

  scope :unused, where(member_id: nil)

  class ActiveRecordWhiplashSession < Hash

    def initialize(opts={})
      @session_id    = opts[:session_id]
      @scope         = opts[:scope]
      @test_column   = opts[:test_column]
      @choice_column = opts[:choice_column]

      self.reload
    end

    def []=(test_name, choice)
      if key?(test_name) && self[test_name] != choice
        @scope.where(@test_column => test_name).first[ @choice_column ] = choice
      else
        @scope.build @test_column => test_name, @choice_column => choice
      end

      store test_name, choice
    end

    def reload
      store :session_id, @session_id

      @scope.each do |record|
        store record.send(@test_column), record.send(@choice_column)
      end

      self
    end

    private

    def record_for(test_name)
      @scope.where(@test_column => test_name).first
    end

  end

  def session
    @session ||= ActiveRecordWhiplashSession.new(
      session_id: self.code, 
      scope: self.social_media_trials, 
      test_column: :key, 
      choice_column: :choice
    )
  end

  def reload
    @session = nil
    super
  end

  private

  def generate_code
    self.code = SecureRandom.urlsafe_base64(8) if self.code.blank? && self.new_record?
  end

end