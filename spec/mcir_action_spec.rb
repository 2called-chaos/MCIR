require 'spec_helper'

Mcir::Core.instance.action("testname", "testdesc") do |t|
  t.prepare { raise "prepared" }
  t.execute { raise "executed" }
end

testificate = Mcir::Core.instance.get_action :testname

describe Mcir::Action do
  it "should have a name and description" do
    testificate.name.should eq "testname"
    testificate.desc.should eq "testdesc"
  end

  it "should prepare" do
    expect{testificate.setup!}.to raise_error "prepared"
  end

  it "should execute" do
    expect{testificate.call}.to raise_error "executed"
  end
end
