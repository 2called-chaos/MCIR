module Mcir
  class Core
    extend ::Forwardable
    include ::Singleton
    include Helper
    include Setup
    include Getters
    include Dispatch

    attr_reader :config, :logger, :args
    attr_writer :exit_code
    def_delegator :@logger, :log
    def_delegator :@logger, :warn
    def_delegator :@logger, :debug

    def exit_code
      @exit_code || 0
    end

    # class method
    def self.dispatch &block
      instance.tap do |i|
        i.dispatch(&block)
        exit i.exit_code
      end
    end

    # =========
    # = Setup =
    # =========
    def initialize
      @actions = {}
      init_logger
      init_config
      init_opts
    end
  end
end
