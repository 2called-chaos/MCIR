class Mcir::Instance
  # Contains getters for instances.
  module Getters
    # Returns the screen name of the instance.
    # @return [String]
    def screen_name
      @config["screen_name"] || "mcir_#{@name}"
    end

    # Returns the port of the instance.
    # @return [Integer]
    def port
      properties["server-port"] || 25565
    end

    # Returns the query port of the instance.
    # @return [Integer]
    def query_port
      properties["query.port"] || 25565
    end

    # Returns the rcon port of the instance.
    # @return [Integer]
    def rcon_port
      properties["rcon.port"] || 25575
    end

    # Returns the server ip of the instance.
    # @return [String]
    def server_ip
      properties["server-ip"].presence || '127.0.0.1'
    end

    # Checks if the server is online by using different checking methods.
    #
    # @param [Symbol] checks List of checks to run.
    # @return [Boolean] true if all checks return true, otherwise false.
    def online? *checks
      # use lockfile per default
      checks << :lock << :screen if checks.empty?

      checks.all? do |check|
        case check.to_sym
          when :lock then lockfile?
          when :screen then screen_status != :unknown
          when :rcon then !!rcon
          when :query then !!query
        end
      end
    end

    # Returns the status of the server screen.
    #
    # @return [Symbol] Either :unknown, :running, :attached, :detached, :uncatched
    def screen_status
      rec = @mcir.screen_list(:name)[screen_name]

      return :unknown unless rec
      return :running unless rec.key? :attached
      return :attached if rec[:attached]
      return :detached unless rec[:attached]
      :uncatched
    end
  end
end
