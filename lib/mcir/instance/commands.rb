class Mcir::Instance
  module Commands
    # bangable methods
    [:java_start, :screen_start, :screen_exec, :screen_kill, :screen_attach].each do |method|
      define_method "#{method}!", ->(*args, &block) do
        self.send(method, *args, &block).execute!
      end
    end

    # Build the command to start the server
    def java_start
      Mcir::Command.new do |cmd|
        cmd << @mcir.config["mcir"]["java_exe"]

        # arguments
        dargs = @config["skip_java_args"] ? "" : @mcir.config["mcir"]["java_args"]
        args  = @config["java_args"]

        cmd << (dargs.split(" ") + args.split(" ")).uniq
        cmd << "-jar #{@config["executable"]}"
      end
    end

    # Build the command to start the server in a screen
    def screen_start
      Mcir::Command.new("screen -mdS #{screen_name}") + java_start
    end

    # Reattaches a screen
    def screen_attach
      Mcir::Command.new("screen -r #{screen_name}", :backticks)
    end

    # Build a command to exec the string in the screen the server is running in.
    # It does NOT check if the server is running or the screen even exists!
    def screen_exec command
      Mcir::Command.new do |cmd|
        cmd << "screen -S #{screen_name}"
        cmd << "-p 0 -X stuff"
        cmd << '"'.concat(stuff_command(command)).concat('"')
      end
    end

    def screen_kill
      Mcir::Command.new ["screen -S #{screen_name} -p 0 -X kill"]
    end

    # ==========
    # = Helper =
    # ==========
    # prepare command for being stuffed into the screen
    def stuff_command cmd
      cmd = cmd.to_s.gsub('"', '\"')
      cmd = cmd[1..-1] if cmd.start_with?("/")
      cmd << "\r"
    end
  end
end
