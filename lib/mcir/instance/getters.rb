class Mcir::Instance
  module Getters
    def screen_name
      @config["screen_name"] || "mcir_#{@name}"
    end

    def port
      properties["server-port"] || 25565
    end

    def query_port
      properties["query.port"] || 25565
    end

    def rcon_port
      properties["rcon.port"] || 25575
    end

    def server_ip
      properties["server-ip"].presence || '127.0.0.1'
    end

    # Checks if the server is online by using different checking methods
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
