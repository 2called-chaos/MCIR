class Mcir::Core
  # Contains getters and accessors.
  module Getters
    # Returns the logger instance and optionally yields it if a block is given.
    #
    # @yieldparam logger [Banana::Logger] Yields the logger to the block
    # @return [Banana::Logger] Logger instance
    def logger
      yield(@logger) if block_given?
      @logger
    end

    # Returns the OptionParser instance and optionally instance_eval a given block.
    #
    # @return [OptionParser] Current OptionParser instance
    # @note This method uses instance_eval, watch out!
    def opt &block
      if block
        @opts.instance_eval(&block)
      else
        @opts
      end
    end

    # Returns the action object if it exists.
    #
    # @param [String, Symbol] name The name of the action
    # @return [Mcir::Action, Nil] Action object or nil if it does not exist
    def get_action name
      @actions[name.to_sym] unless name.nil?
    end

    # @return [Boolean] true if the application is running in dryrun mode.
    def dryrun?
      @dryrun
    end
  end
end
