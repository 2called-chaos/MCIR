module Mcir
  # The main part of the whole thing. Actions are the actual tasks.
  class Action
    attr_reader :mcir, :desc, :config
    alias_method :description, :desc

    # Return the action's name as string
    def name
      @name.to_s
    end

    # =========
    # = setup =
    # =========

    # Initializes a new action object.
    # Will pass a given block to {#setup}.
    #
    # @param [Mcir::Core] mcir MCIR instance
    # @param [String, Symbol] name Name of the action
    # @param [String] desc Description of the action
    # @param [Proc] block Initializer
    def initialize mcir, name, desc = nil, &block
      @mcir = mcir
      @name = name
      @desc = desc
      @config = {}
      setup(&block)
    end

    # Executes the given block which receives the action as argument.
    #
    # @yieldparam action [Mcir::Action] self
    def setup &block
      block.try(:call, self)
    end

    # Sets an preparation block.
    #
    # @param [Proc] block Action setup
    def prepare &block
      @preparator = block
    end

    # Sets an execution block.
    #
    # @param [Proc] block Action handler
    def execute &block
      @executor = block
    end

    # =====================
    # = track descendants =
    # =====================

    # Tracks descendants for automatic action registration.
    # @note This method is considered private API, do not use it.
    # @private
    def self.descendants
      @descendants ||= []
    end

    # Descendant tracking for inherited classes.
    # @note This method is considered private API, do not use it.
    # @private
    def self.inherited(descendant)
      descendants << descendant
    end

    # =============
    # = execution =
    # =============

    # Calls the preparation block.
    def setup!
      @preparator.try(:call)
    end

    # Calls the execution block.
    #
    # @yieldparam instance [Mcir::Instance] The selected instance.
    # @yieldparam args [Array] All non-option arguments passed to the application.
    def call *a
      @executor.try(:call, *a)
    end

    # Returns the prefix for the action.
    # @return [String] Action prefix for the logger.
    def prefix
      "".tap do |o|
        o << "  " if @mcir.logger.debug?
        o << "[#{name}] ".purple
      end
    end
  end
end
