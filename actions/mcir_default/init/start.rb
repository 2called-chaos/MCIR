module Mcir::Action::Init
  class Start < Mcir::Action
    @name = "start"
    @desc = "starts a server"

    def setup!
      @config = { attach: false, inplace: false }
      register_options
    end

    def register_options act = self
      @mcir.opt do
        on("-a", "--attach", desc_def("Attach session after creation", false)) { act.config[:attach] = true }
        on("-i", "--inplace", desc_def("Start server without screen", false)) { act.config[:inplace] = true }
      end
    end

    def call instance, args
      @instance = instance
      abort_if_screen_running! unless @config[:inplace]

      # warn if there is a lockfile
      if instance.online?(:lock)
        @mcir.warn "There is a lockfile #{instance.lockfile_file.ellipsisize}..."
        @mcir.warn "We will continue after 3 seconds, Ctrl+c to abort..."
        sleep 3
        abort_if_screen_running!
      end

      instance.in_home do
        if @config[:inplace]
          @mcir.log "Starting server in place, we're quitting MCIR here..."
          cmd = instance.java_start
          cmd.mode = :exec
          cmd.execute!
        else
          # start screen
          @mcir.log instance.screen_start!

          # attach screen
          if @config[:attach]
            @mcir.run_action(:console) {|act| act.config[:fast] = true }
          end
        end
      end
    end

    def abort_if_screen_running!
      if @instance.online?(:screen)
        @mcir.abort "Can't start ".red << @instance.name.magenta << ", already running!".red
      end
    end
  end
end
