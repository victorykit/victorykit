require "spec_helper"
require "build_checker"
require "rails_on_fire"

class StubChat
  def self.say message
  end
end

describe BuildChecker do
  let(:build_checker) { BuildChecker.new RailsOnFire.new(nil, nil, nil), StubChat }

  it "should warn if current build broke a previously green build" do
    StubChat.should_receive(:say).with("bob broke the build")

    previous_build = {status: 'success', href:'1', builder: 'bob'}
    current_build = {status: 'error', href: '1', builder: 'bob'}
    build_checker.check_build(previous_build, current_build)
  end

  it "should warn if current build has fixed a previous failure" do
    StubChat.should_receive(:say).with("bob has fixed the build")

    previous_build = { status: 'error', href: '1', builder: 'bob' }
    current_build = {status: 'success', href: '1', builder: 'bob'}
    build_checker.check_build(previous_build, current_build)
  end

  it "should not warn if build status has not changed" do
    StubChat.should_not_receive(:say)

    previous_build = { status: 'error', href: '1', builder: 'bob' }
    current_build = { status: 'error', href: '1', builder: 'bob' }

    build_checker.check_build(previous_build, current_build)
  end

  it "should not warn if current build is building" do
    StubChat.should_not_receive(:say)

    previous_build = { status: 'failure', href: '1', builder: 'bob' }
    current_build = { status: 'testing', href: '1', builder: 'bob' }

    build_checker.check_build(previous_build, current_build)
  end
end