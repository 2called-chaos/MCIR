class Mcir::Core
  module Getters
    # returns the logger instance and optionally yields it if a block is given
    def logger
      yield(@logger) if block_given?
      @logger
    end

    def opt &block
      if block
        @opts.instance_eval(&block)
      else
        @opts
      end
    end

    def get_action name
      @actions[name.to_sym] unless name.nil?
    end

    def dryrun?
      @dryrun
    end
  end
end
