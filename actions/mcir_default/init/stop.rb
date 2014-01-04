module Mcir::Action::Init
  class Stop < Mcir::Action
    @name = "stop"
    @desc = "stops a server"

    def setup!
      @config = { force: false, ensure: false, timeout: 10, delay: 15, message: nil }
      register_options
    end

    def register_options act = self
      @mcir.opt do
        on("-f", "--force", desc_def("Kill the screen immediately, ignores all following options", false)) { act.config[:force] = true }
        on("-e", "--ensure", desc_def("Kill the screen if the server didn't stop after timeout is reached", false)) { act.config[:ensure] = true }
        on("-t", "--timeout N", Integer, desc_def("Wait N seconds for the server to stop", 10)) {|t| act.config[:timeout] = t }
        on("-d", "--delay [N]", Integer, desc_def("Wait N seconds before stopping the server if --message is given)", 15)) {|t| act.config[:delay] = t }
        on("-m", "--message MSG", String, desc_def("Send message to server before waiting --delay")) {|t| act.config[:message] = t }
        on("-k", "--kick [MSG]", desc_def("Kick all players before the server will shutdown", false)) {|t| act.config[:kick] = t }
      end
    end

    def call instance, args
      @instance = instance

      if !@instance.online?(:screen)
        @mcir.abort "Can't stop ".red << "#{@instance.name}".magenta << ", not running!".red
      else
        @config[:force] ? force_shutdown : graceful_shutdown
      end
    end

    def force_shutdown
      @mcir.warn "Killing screen session for ".red << "#{@instance.name}".magenta << "!".red
      @mcir.logger.log_with_print do
        @mcir.warn "Abort within 3 seconds".red
        sleep 1
        3.times{ print ".".red; sleep 1 }
      end
      @mcir.warn "Killing...".red
      @instance.screen_kill!
      wait_for_server_to_shutdown
    end

    def graceful_shutdown
      # before stop message
      if @config[:message]
        @mcir.log "Sending message to instance..."
        @instance.screen_exec! "say #{@config[:message]}"
        @mcir.log "Waiting ".yellow << "#{@config[:delay]} seconds...".magenta
        sleep @config[:delay]
      end

      # kick players
      if @config.key? :kick
        @mcir.log "Kicking all players..."
        @instance.screen_exec! "kickall #{@config[:kick] || "Server closed"}"
        sleep 3
      end

      # @todo issue save-all

      # send stop to server
      @instance.screen_exec! @instance.config["stop_command"] || "stop"
      force_shutdown if !wait_for_server_to_shutdown && @config[:ensure]
    end

    def wait_for_server_to_shutdown
      if @config[:timeout] > 0.0
        begin
          time = @mcir.measure do
            @mcir.logger.log_with_print do
              @mcir.log "Wait ".yellow << "#{@config[:timeout]} seconds".magenta << " for instance to stop".yellow
              Timeout::timeout(@config[:timeout]) do
                while @instance.online?(:screen)
                  print "."
                  sleep 1
                end
              end
            end
          end
          @mcir.log  "Instance ".green <<
                     "#{@instance.name}".magenta <<
                     " successfully stopped (".green <<
                     "#{time[:dist]}".magenta <<
                     ")!".green
          return true
        rescue Timeout::Error => e
          @mcir.warn "Instance ".red <<
                     "#{@instance.name}".magenta <<
                     " failed to stop within ".red <<
                     "#{@config[:timeout]} seconds".purple <<
                     "!".red
          return false
        end
      end
    end
  end
end
