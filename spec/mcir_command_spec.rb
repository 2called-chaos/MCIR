require 'spec_helper'

describe Mcir::Command do
  it "should concat commands" do
    cmd1 = Mcir::Command.new ["java", "farg", "sarg"]
    cmd2 = Mcir::Command.new ["screen", "-mdS"]
    cmd3_a = cmd2 + cmd1

    cmd1.should eq ["java", "farg", "sarg"]
    cmd2.should eq ["screen", "-mdS"]
    cmd3_a.should eq ["screen", "-mdS", "java", "farg", "sarg"]
  end
end
