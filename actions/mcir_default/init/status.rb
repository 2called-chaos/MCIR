module Mcir::Action::Init
  class Status < Mcir::Action
    @name = "status"
    @desc = "shows the status of a server"

    def setup!
      @config = { lock: true, screen: true, rcon: false, query: false }
      register_options
    end

    def register_options act = self
      c = act.config
      @mcir.opt do
        on("-a", "--all", desc_def("Check with every method")) { c.keys.each{|k| c[k] = true } }
        on("-l", "--[no-]lock", desc_def("Check lockfile", true)) {|v| c[:lock] = v }
        on("-s", "--[no-]screen", desc_def("Check screen", true)) {|v| c[:screen] = v }
        on("-r", "--[no-]rcon", desc_def("Check rcon", false)) {|v| c[:rcon] = v }
        on("-q", "--[no-]query", desc_def("Check query", false)) {|v| c[:query] = v }
      end
    end

    def call instance, args
      stati = {}.tap do |r|
        r[:lock]   = instance.online?(:lock)   if config[:lock]
        r[:screen] = instance.online?(:screen) if config[:screen]
        r[:rcon]   = instance.online?(:rcon)   if config[:rcon]
        r[:query]  = instance.online?(:query)  if config[:query]
      end

      if @mcir.logger.enabled?
        @mcir.logger.info @mcir.cgr!(stati[:lock],   "Lock    ", "ONLINE", "OFFLINE") if stati.key?(:lock)
        @mcir.logger.info @mcir.cgr!(stati[:screen], "Screen  ", "ONLINE", "OFFLINE") if stati.key?(:screen)
        @mcir.logger.info @mcir.cgr!(stati[:rcon],   "Rcon    ", "ONLINE", "OFFLINE") if stati.key?(:rcon)
        @mcir.logger.info @mcir.cgr!(stati[:query],  "Query   ", "ONLINE", "OFFLINE") if stati.key?(:query)
      else
        puts stati.to_json
      end
    end
  end
end
