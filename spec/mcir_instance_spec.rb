require 'spec_helper'

testificate = Mcir::Instance.new(Mcir::Core.instance, "rspec")
testificate.config["home"].gsub! "%MCIR_ROOT%", MCIR_ROOT

describe Mcir::Instance do
  it "should parse server plist" do
    testificate.properties.should eq({
      "a" => "b",
      "b" => 5,
      "c" => true,
      "d" => false,
      "d.a" => "a"
    })
  end

  # =========
  # = Paths =
  # =========
  it "should distinct paths" do
    testificate.distinct_relative_path("foo.bar").should eq "#{testificate.config["home"]}/foo.bar"
    testificate.distinct_relative_path("~/foo.bar").should eq "~/foo.bar"
    testificate.distinct_relative_path("/foo.bar").should eq "/foo.bar"
  end

  # ======
  # = IO =
  # ======
  it "should have a serverlog handle" do
    testificate.logfile.should be_a Mcir::Instance::ServerLog
  end

  it "should write and read to the serverlog" do
    lf = testificate.logfile(mode: "w")
    lf.write("foo")
    lf.close
    testificate.logfile.read.should eq "foo"
  end

  it "should tail a file" do
    lf = testificate.logfile(mode: "w")
    lf.puts("tail")
    lf.puts("again")
    lf.close

    testificate.logfile(tail: true, n: 100).should eq ["tail\n", "again\n"]
  end

  it "should tailf a file" do
    begin
      lf = testificate.logfile(mode: "w")
      Thread.new { sleep(1); lf.puts("tailf"); lf.flush }

      testificate.logfile(tail: true, f: true, n: 100) do |l|
        l.should eq "tailf\n"
        break
      end
    ensure
      lf.close
    end
  end

  # ============
  # = Commands =
  # ============
  it "should build java_start command" do
    testificate.java_start.to_s.should eq "java -server -Xms1048M -Xmx2048M -jar minecraft_server.jar nogui"
    testificate.java_start.to_a.should eq ["java", ["-server", "-Xms1048M", "-Xmx2048M"], "-jar minecraft_server.jar nogui"]
  end

  it "should build a screen_start command" do
    cmd = testificate.screen_start.to_a[0..1]
    cmd.should eq ["screen -mdS mcir_rspec", "java"]
  end

  it "should build a screen_exec command" do
    testificate.screen_exec("foo").to_a.should eq ["screen -S mcir_rspec", "-p 0 -X stuff", %{"foo\r"}]
  end

  it "should properly stuff commands" do
    testificate.stuff_command(%{/msg "this is a message"}).should eq %{msg \\"this is a message\\"\r}
  end

  # ===========
  # = Getters =
  # ===========
  it "should detect lockfile" do
    testificate.lockfile?.should be_false
    testificate.online?(:lock).should be_false
    FileUtils.touch(testificate.lockfile_file)

    testificate.lockfile?.should be_true
    testificate.online?(:lock).should be_true
    File.delete(testificate.lockfile_file)
  end

  it "should detect running screens" do
    testificate.screen_status.should be :unknown
    testificate.online?(:screen).should be_false

    # start screen
    Mcir::Command.new("#{testificate.screen_start.shift} sleep 60").execute!

    testificate.screen_status.should_not be :unknown
    testificate.online?(:screen).should be_true

    # kill screen
    testificate.screen_kill!
    sleep 1

    testificate.screen_status.should be :unknown
    testificate.online?(:screen).should be_false
  end
end
