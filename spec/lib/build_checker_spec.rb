require "spec_helper"
require "build_checker"
require "rails_on_fire"
describe BuildChecker do
  let(:build_checker) { BuildChecker.new RailsOnFire.new(nil)}

  it "should warn if current build broke a previously green build" do
    VictoryKitChat.should_receive(:say).with("bob broke the build")

    previous_build = {status: 'success', href:'1', builder: 'bob'}
    current_build = {status: 'error', href: '1', builder: 'bob'}
    build_checker.check_build(previous_build, current_build)
  end

  it "should warn if current build has fixed a previous failure" do
    VictoryKitChat.should_receive(:say).with("bob has fixed the build")

    previous_build = { status: 'error', href: '1', builder: 'bob' }
    current_build = {status: 'success', href: '1', builder: 'bob'}
    build_checker.check_build(previous_build, current_build)
  end

  it "should not warn if build status has not changed" do
    VictoryKitChat.should_not_receive(:say)

    previous_build = { status: 'error', href: '1', builder: 'bob' }
    current_build = { status: 'error', href: '1', builder: 'bob' }

    build_checker.check_build(previous_build, current_build)
  end

  it "should not warn if current build is building" do
    VictoryKitChat.should_not_receive(:say)

    previous_build = { status: 'failure', href: '1', builder: 'bob' }
    current_build = { status: 'testing', href: '1', builder: 'bob' }

    build_checker.check_build(previous_build, current_build)
  end
end