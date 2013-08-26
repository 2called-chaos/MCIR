module Mcir
  # Application core functionality.
  class Core
    extend ::Forwardable
    include ::Singleton
    include Helper
    include Setup
    include Getters
    include Dispatch

    attr_reader :config, :logger, :args, :actions
    attr_writer :exit_code
    def_delegator :@logger, :log
    def_delegator :@logger, :warn
    def_delegator :@logger, :debug

    # Returns the current set exit code for the application.
    #
    # @return [Integer] Current set error code or 0 if not set.
    def exit_code
      @exit_code || 0
    end

    # Shortcut method to dispatch MCIR. You may not need to call this method.
    def self.dispatch &block
      instance.tap do |i|
        i.dispatch(&block)
        exit i.exit_code
      end
    end

    # =========
    # = Setup =
    # =========
    # Initializes the application.
    def initialize
      @actions = {}
      init_logger
      init_config
      init_opts
    end
  end
end
