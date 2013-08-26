# Encoding: utf-8
class Mcir::Core
  # Contains helper methods.
  module Helper
    # Log each line of the given string seperately.
    #
    # @param [String] str String to log per line.
    def eachlog str
      str.split("\n").each{|s| log(s) }
    end

    # Shows a warning message and/or the help and/or abort the application.
    # You can omit the message if you don't need one (or pass nil).
    #
    # @param [String] msg Message to abort with.
    # @option opts [Boolean] exit (true) Exit the application (SystemExit).
    # @option opts [Integer] code (1) The exit code when exiting the application.
    # @option opts [Boolean] help (false) Print the application help.
    def abort msg, opts = {}
      opts = msg if msg.is_a?(Hash)
      opts = { exit: true, code: 1, help: false }.merge(opts)

      if !msg.is_a?(Hash) && msg.present?
        Array.wrap(msg).flatten.each do |m|
          @logger.log(m, :abort)
        end
      end

      show_help(false) if opts[:help]
      self.exit_code = opts[:code] if opts[:code]
      exit(opts[:code]) if opts[:exit]
    end

    # Shows the application help.
    #
    # @param [Boolean] exit Exit the application with code 0 after showing the help.
    def show_help exit = true
      puts "\n#{opt}\n"

      # actions
      unless @called_action
        col_length = @actions.keys.map(&:length).max + 2
        puts "Available actions".purple.underline.rjust(col_length + 25)
        @actions.keys.sort_by(&:downcase).each do |key|
          action = @actions[key]
          puts "#{action.name.rjust(col_length)}" << " … ".blue << "#{action.description}".yellow
        end
      end

      abort(code: 0) if exit
    end

    # Statushelper, returns colored strings based on the condition.
    #
    # @param condition Uses green text if condition evaluates to true, red text otherwise.
    # @param [String] green Green or true text
    # @param [String] red Red or false text
    # @example
    #   cgr instance.online?, "ONLINE", "OFFLINE"
    def cgr condition, green, red
      condition ? green.green : red.red
    end

    # Same as {#cgr} but with a prefix. The prefix and green/red text is automatically separated by an
    # space character.
    #
    # @param condition (see #cgr)
    # @param [String] desc Description text which will be prefixed. Will be colorized yellow.
    # @param green (see #cgr)
    # @param red (see #cgr)
    # @example
    #   cgr! instance.online?, "Server is", "ONLINE", "OFFLINE"
    def cgr! condition, desc, green, red
      desc.yellow << " " << cgr(condition, green, red)
    end

    # Handles exceptions depending on kind and the application's debug setting.
    #
    #   * `SystemExit` exceptions will just be ignored.
    #   * `Interrupt` exceptions will be silently raised again.
    #   * All other exceptions will cause an application {#abort termination}. It will display a decent
    #     error message unless the debug mode is enabled. Then it would just raise the exception giving
    #     you a stack trace.
    #
    # @param [Exception] e Any kind of exception.
    # @param [String] msg A message to print in the abort message.
    def trap_exception e, msg
      return if e.is_a?(SystemExit)
      throw_further = @logger.debug? || e.is_a?(Interrupt)

      msg = Array.wrap(msg)
      msg << "  => Message: #{e.message.presence || e.inspect}".yellow
      msg << "  => Run with --debug to get a stack trace".yellow if !throw_further

      abort msg, exit: !throw_further
      raise e if throw_further
    end

    # distinct optional-required-optional arguments
    # @note This method is considered private API, do not use it.
    # @private
    def distinct_action_and_instance
      fa = ARGV.shift.presence unless ARGV[0].to_s.start_with?("-")
      sa = ARGV.shift.presence unless ARGV[0].to_s.start_with?("-")

      if fa && sa
        return [sa, fa]
      elsif fa && !sa
        return [fa, @config["mcir"]["default_instance"]]
      end
    end

    # Get's and parses a list of available screens.
    #
    # @param [Symbol] by The field to use as index for the result hash. (pid/name/rest/line)
    # @return [Hash] A hash with some information about running screens.
    # @example
    #   {
    #     "mcir_my_instance" => {
    #       pid: 1234,
    #       name: "mcir_my_instance",
    #       attached: true,
    #       rest: "(07/17/2013 01:11:23 AM)(Detached)",
    #       line: "1234.mcir_my_instance\t(07/17/2013 01:11:23 AM)\t(Detached)",
    #     }
    #   }
    def screen_list by = :pid
      screens = {}.tap do |r|
        rows = `screen -ls`.split("\n").select{ |l| l.start_with?("\t") }.map(&:strip)

        rows.each do |row|
          cols = row.split("\t").map(&:strip)
          scr  = cols.shift.split(".")
          rest = cols.join
          fatt = rest.downcase.include?("attached") || rest.downcase.include?("detached")

          res = {
            pid: scr.first.to_i,
            name: scr[1..-1].join("."),
            rest: rest,
            line: row,
          }
          res[:attached] = rest.downcase.include?("attached") if fatt

          r[res[by]] = res
        end
      end
    end

    # Measures the time needed by a given block.
    #
    # @return [Hash] Result hash (see example)
    # @example
    #   mcir.measure { sleep 5 }
    #   {
    #     start: Time<2013-07-21 23:25:54 UTC>, # Start time
    #     result: 5,                            # Return value of the block
    #     stop: Time<2013-07-21 23:25:59 UTC>,  # Stop time
    #     diff: 5.000099503,                    # Runtime in seconds
    #     time: Time<1970-01-01 00:00:05 UTC>,  # Runtime as Time object
    #     dist: "05.000"                        # Humand friendly representation of :diff
    #   }
    def measure &block
      {}.tap do |r|
        r[:start]  = Time.now.utc
        r[:result] = block.call
        r[:stop]   = Time.now.utc
        r[:diff]   = r[:stop] - r[:start]
        r[:time]   = Time.at(r[:diff]).utc

        format = ".%L"
        format = "%S#{format}" if r[:diff] > 1
        format = "%M:#{format}" if r[:diff] > 60
        format = "%H:#{format}" if r[:diff] > 3600
        r[:dist] = r[:time].strftime(format)
      end
    end
  end
end
