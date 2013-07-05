require 'spec_helper'

testificate = Mcir::Core.instance
testificate.logger.disable

describe Mcir::Core do
  it "should initialize a logger" do
    testificate.logger.should be_a Banana::Logger
  end

  it "should load a config" do
    testificate.config.should be_a Hash
    testificate.config["mcir"].should be_a Hash
    testificate.config["instances"].should be_a Hash
    testificate.opt.should be_a OptionParser
  end

  it "should register default actions" do
    was = testificate.instance_variable_get(:@actions).count
    testificate.register_action_classes
    testificate.instance_variable_get(:@actions).count.should_not eq was
  end

  it "should register custom actions" do
    testificate.action :test_custom_action, "a test task" do |t|
      t.execute { raise "custom action executed" }
    end

    act = testificate.get_action(:test_custom_action)
    act.should be_a Mcir::Action
    expect{act.call}.to raise_error "custom action executed"
  end
end
