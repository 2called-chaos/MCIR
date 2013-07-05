# Stolen from my private library (BananaLib)
module Banana
  class Logger
    attr_accessor :colorize, :prefix
    COLORMAP = {
      black: 30,
      red: 31,
      green: 32,
      yellow: 33,
      blue: 34,
      magenta: 35,
      cyan: 36,
      white: 37,
    }

    def initialize scope
      @scope = scope
      @startup = Time.now.utc
      @colorize = true
      @prefix = ""
      @enabled = true
      @channel = Kernel
      @method = :puts
      @logged = 0
      @levels = {
        info: { color: "yellow", enabled: true },
        warn: { color: "red", enabled: true },
        abort: { color: "red", enabled: true },
        debug: { color: "blue", enabled: true },
      }
    end

    def attach channel
      @channel = channel
    end

    def log_level levels = {}
      levels.each do |level, color|
        @levels[level.to_sym] ||= {}
        @levels[level.to_sym][:color] = color
      end
    end

    def ensure_prefix prefix, &block
      old_prefix, @prefix = @prefix, prefix
      block.call
    ensure
      @prefix = old_prefix
    end

    def log_with_print clear = true, &block
      old_method, old_logged = @method, @logged
      @method, @logged = :print, 0
      block.call
    ensure
      puts if clear && @logged > 0
      @method = old_method
      @logged = old_logged
    end

    def debug?
      enabled? :debug
    end

    def enabled? level = nil
      level.nil? ? @enabled : @levels[level.to_sym][:enabled]
    end

    def disabled? level = nil
      !enabled?(level)
    end

    def disable level = nil
      if level.nil?
        @enabled = false
      else
        @levels[level.to_sym][:enabled] = false
      end
    end

    def enable level = nil
      if level.nil?
        @enabled = true
      else
        @levels[level.to_sym][:enabled] = true
      end
    end

    def colorize str, color
      ccode = COLORMAP[color.to_sym] || raise(ArgumentError, "Unknown color #{color}!")
      "\e[#{ccode}m#{str}\e[0m"
    end

    def log msg, type = :info
      return if !@enabled || !@levels[type][:enabled]
      if @levels[type.to_sym] || !@levels.key?(type.to_sym)
        time = Time.at(Time.now.utc - @startup).utc
        timestr = "[#{time.strftime("%H:%M:%S.%L")} #{type.to_s.upcase}]\t"

        if @colorize
          msg = "#{colorize(timestr, @levels[type.to_sym][:color])}" <<
                "#{@prefix}" <<
                "#{colorize(msg, @levels[type.to_sym][:color])}"
        else
          msg = "#{timestr}#{@prefix}#{msg}"
        end
        @logged += 1
        @channel.send(@method, msg)
      end
    end
    alias_method :info, :log

    def debug msg
      log(msg, :debug)
    end

    def warn msg
      log(msg, :warn)
    end
  end
end
