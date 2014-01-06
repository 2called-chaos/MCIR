class Mcir::Core
  # Contains dispatching methods.
  module Dispatch
    # Runs an action's setup! method.
    #
    # @param [String, Symbol, Mcir::Action] name Action you want to prepare
    # @return [Boolean] true if the action was prepared successfully
    def prepare_action name
      action = name.is_a?(Mcir::Action) ? name : get_action(name)
      if action
        begin
          @logger.debug ">prepare `#{action.name}'"
          @logger.ensure_prefix(action.prefix) { action.setup! }
          @logger.debug "/prepared `#{action.name}'"
          return true
        rescue Exception => e
          trap_exception e, "Failed to setup action task `#{action.name}'".red
          return false
        end
      end
    end

    # Forwards an action to the actual dispatcher.
    #
    # @param [String, Symbol, Mcir::Action] name Action you want to prepare
    # @param [Mcir::Instance] instance Define a different instance for that action
    # @return (see #dispatch!)
    def dispatch_action name, instance = @current_instance
      action = name.is_a?(Mcir::Action) ? name : get_action(name)
      dispatch!(action, instance, action.try(:name) || name)
    end

    # {#prepare_action setup} and {#dispatch_action run} an action in one step.
    # A optional block will be called after seting up and before dispatching the
    # action.
    #
    # @param [String, Symbol, Mcir::Action] name Action you want to prepare
    # @param [Mcir::Instance] instance Define a different instance for that action
    # @param [Proc] block Block to further setup the action.
    # @yieldparam action [Mcir::Action]
    # @yieldparam instance [Mcir::Instance]
    # @return (see #dispatch_action)
    def run_action name, instance = @current_instance, &block
      action = name.is_a?(Mcir::Action) ? name : get_action(name)
      prepare_action(action)
      block.try(:call, action, instance)
      dispatch_action(action, instance)
    end

    # Dispatch preparation for the main action.
    # You may not need to call this method.
    def dispatch &block
      # run action definitions
      block.call(self)

      # get action and instance
      @called_action, @called_instance = distinct_action_and_instance
      action = get_action(@called_action)
      @current_instance = instance = Mcir::Instance.new(self, @called_instance)
      @logger.debug "dispatching action `#{@called_action}' on instance `#{@current_instance.name}'"

      # prepare action
      prepare_action(action)

      # parse arguments
      begin
        @args = opt.parse!(ARGV)
      rescue OptionParser::InvalidArgument => e
        abort(e.message, help: true)
      rescue OptionParser::InvalidOption => e
        abort(e.message, help: true)
      end

      # dispatch!
      r = ARGV.select{|s| s.start_with?("-")}
      if r.length > 0
        abort("Unknown parameters #{r.inspect}", help: true)
      else
        dispatch!(action, instance)
        @logger.debug "/dispatched"
      end
    rescue Interrupt
      @logger.info "Interrupted, exiting"
    end

    # Actual dispatches an action by calling it.
    # You may not need to call this method directly.
    #
    # @param [Mcir::Action] action The action to dispatch.
    # @param [Mcir::Instance] instance The instance to use. You need one even with global commands.
    # @param [String, Symbol] called_action Used for error messages.
    # @return [Boolean] true if the action was executed successfully, false otherwise.
    def dispatch! action, instance, called_action = @called_action
      unless action.is_a?(Mcir::Action)
        abort(called_action.blank? ? "Specify at least an action" : "Unknown action `#{called_action}'", help: true)
      end
      @logger.debug "processing action `#{action.name}'"

      begin
        @logger.ensure_prefix(action.prefix) { action.call(instance, @args) }
        return true
      rescue Exception => e
        trap_exception e, "Failed to execute action task `#{action.name}'".red
        return false
      ensure
        @logger.debug "/processed action `#{action.name}'"
      end
    end
  end
end
