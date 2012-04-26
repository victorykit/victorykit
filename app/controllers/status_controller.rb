class StatusController < ApplicationController
  def index
    @commit_hash = ENV['COMMIT_HASH']
  end
end
