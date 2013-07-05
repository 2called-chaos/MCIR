
class Mcir::Action::Tail < Mcir::Action
  @name = "tail"
  @desc = "tails the server log"

  def setup!
    @config = { backlog: 25, interval: 1 }
    register_options
  end

  def register_options act = self
    @mcir.opt do
      on("-b", "--backlog N", Integer, desc_def("shows the last N lines of the log")) {|n| act.config[:backlog] = n }
      on("-f", "--follow", desc_def("follow the file, wait for new contents")) { act.config[:follow] = true }
      on("-i", "--interval", Float, desc_def("tail interval in seconds", 1)) {|n| act.config[:interval] = n }
      on("-t", "--timeout N", Integer, desc_def("wait for N seconds, then abort", 30)) {|n| act.config[:timeout] = n }
      on("-w", "--wait MSG", desc_def("follow file until MSG is found (incl. backlog!)"), desc_def("MSGs starting with a slash are evaluated as regex")) do |msg|
        act.config[:follow] = true
        act.config[:wait] = msg
      end
    end
  end

  def call instance, args
    @instance = instance
    @config[:wait] = eval(@config[:wait]) if @config[:wait].try(:start_with?, "/")

    time = @mcir.measure do
      begin
        if @config.key?(:timeout)
          Timeout::timeout(@config[:timeout] || 30) { call_tailer }
        else
          call_tailer
        end
      rescue RuntimeError => e
        raise unless e.message == "found"
      end
    end
  rescue Timeout::Error => e
    @mcir.abort "Execution limit of ".red << "#{@config[:timeout] || 30} seconds".magenta << " exceeded!".red
  ensure
    if @config[:wait] && @waitmatch
      if @mcir.logger.enabled?
        @mcir.eachlog "Found message after #{time.try(:[], :dist)}: #{@waitmatch}"
      else
        puts({ result: @waitmatch }.to_json)
      end
    end
  end

  def call_tailer
    @instance.logfile(tail: true, n: @config[:backlog], f: @config.key?(:follow), interval: @config[:interval]) do |line|
      if @mcir.logger.enabled?
        @mcir.log line.strip
      else
        puts line.strip
      end

      if pattern = @config[:wait]
        if pattern.is_a?(Regexp) && match = line.match(pattern) then @waitmatch = match end
        if pattern.is_a?(String) && line.include?(pattern) then @waitmatch = line end
        raise RuntimeError, "found" if @waitmatch
      end
    end
  end

  def handle_line line

  end
end
