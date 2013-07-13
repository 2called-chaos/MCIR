class Mcir::Instance
  module Rcon
    def rcon reconnect = false
      @_rcon = nil if reconnect
      if !@_rcon && properties["enable-rcon"]
        @_rcon = RCON::Minecraft.new(server_ip, rcon_port)
        @_rcon.auth properties["rcon.password"] if properties["rcon.password"].present?
      end
      @_rcon
    rescue
      return false
    end

    def query mode = :simple
      if properties["enable-query"]
        if mode == :simple
          Query::simpleQuery(server_ip, query_port)
        else
          Query::fullQuery(server_ip, query_port)
        end
      end
    rescue
      return false
    end
  end
end
