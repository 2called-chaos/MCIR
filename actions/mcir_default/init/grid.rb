module Mcir::Action::Init
  class Grid < Mcir::Action
    @name = "grid"
    @desc = "shows status of all configured instances"

    def setup!
      @mcir.prepare_action :status
    end

    def call instance, args
      @mcir.config["instances"].each do |name, _|
        instance = Mcir::Instance.new(@mcir, name)
        @mcir.logger.raw(nil, :puts)
        @mcir.log "Showing ".yellow << instance.name.magenta
        begin
          @mcir.dispatch_action :status
        rescue
          @mcir.warn "Failed to get status of instance " << instance.name.magenta
        end
      end
    end
  end
end
