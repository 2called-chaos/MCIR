module Mcir::Action::Init
  class Console < Mcir::Action
    @name = "console"
    @desc = "attaches the screen with the console"

    def setup!
      @config = { fast: false }
      register_options
    end

    def register_options act = self
      @mcir.opt do
        on("-f", "--fast", desc_def("Attach a screen much faster", false)) { act.config[:fast] = true }
      end
    end

    def call instance, args
      if !instance.online?(:screen)
        @mcir.abort "Can't attach ".red << instance.name.magenta << ", not running!".red
      else
        if instance.screen_status == :attached
          @mcir.abort "Can't attach ".red << instance.name.magenta << ", already attached!".red
        else
          @mcir.log "Attaching console for ".yellow << "#{instance.name}".magenta << "...".yellow
          @mcir.log "Press ".yellow << "Ctrl-A".magenta << " + ".yellow << "Ctrl+D".magenta << " successively to detach".yellow
          sleep @config[:fast] ? 0.25 : 3
          instance.screen_attach!
        end
      end
    end
  end
end
