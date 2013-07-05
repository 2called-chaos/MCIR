
class Mcir::Action::Rcon < Mcir::Action
  @name = "rcon"
  @desc = "provides rcon accessors"

  def setup!
    register_options
  end

  def register_options act = self
    @mcir.opt do
      on("-c", "--command CMD", desc_def("executes the given command and return the result")) {|c| act.config[:command] = c }
      on("-q", "--query [simple|full]", desc_def("returns the result of an query", "simple")) {|c| act.config[:query] = c || "simple" }
    end
  end

  def call instance, args
    if @config[:command]
      call_command(@config[:command], instance)
    elsif @config[:query]
      call_query(@config[:query], instance)
    else
      @mcir.abort "Either provide a --command or --query."
    end
  end

  def call_query query, instance
    query = instance.query(query.to_s.to_sym)

    if !query
      if !instance.properties["enable-query"]
        @mcir.abort "Query is not enabled in server.properties"
      elsif !instance.online?(:screen)
        @mcir.abort "Instance is not running"
      else
        @mcir.abort "Can't query server, please check configuration."
      end
    end

    if @mcir.logger.enabled?
      @mcir.eachlog "Server query".blue.underline << " = " << query.ai
    else
      puts query.is_a?(Hash) ? query.to_json : { failed: query }.to_json
    end
  end

  def call_command command, instance
    if !instance.rcon
      if !instance.properties["enable-rcon"]
        @mcir.abort "Rcon is not enabled in server.properties"
      elsif !instance.online?(:screen)
        @mcir.abort "Instance is not running"
      else
        @mcir.abort "Can't connect to rcon, please check configuration."
      end
    else
      time = @mcir.measure { instance.rcon.command @config[:command] }
      result = time[:result]
    end

    if @mcir.logger.enabled?
      @mcir.log "Rcon Result:".blue.underline << "  in #{time[:dist]}".yellow
      @mcir.eachlog result.strip
    else
      puts({ result: result, time: time.except(:result) }.to_json)
    end
  end
end
