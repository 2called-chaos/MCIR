# Encoding: utf-8
class Mcir::Core
  module Helper
    def eachlog str
      str.split("\n").each{|s| log(s) }
    end

    # shows a warning message and/or the help and/or abort the application
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

    # show the application help
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

    def cgr condition, green, red
      condition ? green.green : red.red
    end

    def cgr! condition, desc, green, red
      desc.yellow << " " << cgr(condition, green, red)
    end

    # handle exceptions
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
    def distinct_action_and_instance
      fa = ARGV.shift.presence unless ARGV[0].to_s.start_with?("-")
      sa = ARGV.shift.presence unless ARGV[0].to_s.start_with?("-")

      if fa && sa
        return [sa, fa]
      elsif fa && !sa
        return [fa, @config["mcir"]["default_instance"]]
      end
    end

    # get's and parses a list of available screens
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
