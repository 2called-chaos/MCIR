class Mcir::Core
  module Dispatch
    # run an action's setup method
    def prepare_action name
      action = name.is_a?(Mcir::Action) ? name : get_action(name)
      if action
        begin
          @logger.debug ">prepare `#{action.name}'"
          @logger.ensure_prefix(action.prefix) { action.setup! }
          @logger.debug "/prepared `#{action.name}'"
        rescue Exception => e
          trap_exception e, "Failed to setup action task `#{action.name}'".red
        end
      end
    end

    # forwards an action to the actual dispatcher
    def dispatch_action name, instance = @current_instance
      action = name.is_a?(Mcir::Action) ? name : get_action(name)
      dispatch!(action, instance, name)
    end

    # setup and run an action in one step
    def run_action name, instance = @current_instance, &block
      action = name.is_a?(Mcir::Action) ? name : get_action(name)
      prepare_action(action)
      block.try(:call, action, instance)
      dispatch_action(action, instance)
    end

    # main action dispatch preparation
    def dispatch &block
      # run action definitions
      block.call(self)

      # get action and instance
      @called_action, @called_instance = distinct_action_and_instance
      action = get_action(@called_action)
      @current_instance = instance = Mcir::Instance.new(self, @called_instance)
      @logger.debug "dispatching action `#{@called_action}' on instance `#{@called_instance}'"

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

    # actual dispatch which calls the action's executor
    def dispatch! action, instance, called_action = @called_action
      unless action.is_a?(Mcir::Action)
        abort(called_action.blank? ? "Specify at least an action" : "Unknown action `#{called_action}'", help: true)
      end
      @logger.debug "processing action `#{action.name}'"

      begin
        @logger.ensure_prefix(action.prefix) { action.call(instance, @args) }
      rescue Exception => e
        trap_exception e, "Failed to execute action task `#{action.name}'".red
      ensure
        @logger.debug "/processed action `#{action.name}'"
      end
    end
  end
end
