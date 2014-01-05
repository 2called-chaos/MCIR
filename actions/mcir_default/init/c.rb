module Mcir::Action::Init
  class C < Mcir::Action
    @name = "c"
    @desc = "attaches the screen with the console instantly (shortcut)"

    def call instance, args
      if !instance.online?(:screen)
        @mcir.abort "Can't attach ".red << "#{instance.name}".magenta << ", not running!".red
      else
        if instance.screen_status == :attached
          @mcir.abort "Can't attach ".red << "#{instance.name}".magenta << ", already attached!".red
        else
          @mcir.log "Attaching console for ".yellow << "#{instance.name}".magenta << "...".yellow
          instance.screen_attach!
        end
      end
    end
  end
end
