class Mcir::Instance
  # Contains command builders for instances.
  module Commands
    # bangable methods
    [:java_start, :screen_start, :screen_exec, :screen_kill, :screen_attach].each do |method|
      define_method "#{method}!", ->(*args, &block) do
        self.send(method, *args, &block).execute!
      end
    end

    # Builds the command to start the server.
    # @return [Mcir::Command]
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

    # Builds the command to start the server in a screen.
    # @return [Mcir::Command]
    def screen_start
      Mcir::Command.new("screen -mdS #{screen_name}") + java_start
    end

    # Builds a command to attach the server screen.
    # @return [Mcir::Command]
    def screen_attach
      Mcir::Command.new("screen -r #{screen_name}", :backticks)
    end

    # Builds a command to exec the string in the screen the server is running in.
    # It does NOT check if the server is running or the screen even exists!
    #
    # @param [String] command Server command to execute (will be automatically {#stuff_command stuffed}).
    # @return [Mcir::Command]
    def screen_exec command
      Mcir::Command.new do |cmd|
        cmd << "screen -S #{screen_name}"
        cmd << "-p 0 -X stuff"
        cmd << '"'.concat(stuff_command(command)).concat('"')
      end
    end

    # Builds a command to kill the server screen. May not be good.
    #
    # @return [Mcir::Command]
    def screen_kill
      Mcir::Command.new ["screen -S #{screen_name} -p 0 -X kill"]
    end

    # ==========
    # = Helper =
    # ==========
    # Prepares a server command for being stuffed into the screen.
    #
    # @param [String] cmd Server command to stuff.
    # @return [String] Prepared command string.
    def stuff_command cmd
      cmd = cmd.to_s.gsub('"', '\"')
      cmd = cmd[1..-1] if cmd.start_with?("/")
      cmd << "\r"
    end
  end
end
