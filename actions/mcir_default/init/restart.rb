module Mcir::Action::Init
  class Restart < Mcir::Action
    @name = "restart"
    @desc = "restarts a server"

    def setup!
      @mcir.prepare_action :stop
      @mcir.prepare_action :start
    end

    def call instance, args
      @mcir.log "Restarting ".yellow << "#{instance.name}".magenta
      @mcir.dispatch_action :stop
    ensure
      @mcir.dispatch_action :start
    end
  end
end
