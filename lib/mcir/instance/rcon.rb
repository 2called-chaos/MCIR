class Mcir::Instance
  # Contains rcon and query functionalities.
  module Rcon
    # Returns the rcon handle (singleton).
    #
    # @param [Boolean] reconnect Make new connection if set to true.
    # @return Rcon instance or false if something went wrong.
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

    # Makes a server query and returns the result.
    #
    # @param [Symbol] mode Query mode (simple or full)
    # @return [Hash] Query result or false if something went wrong.
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
