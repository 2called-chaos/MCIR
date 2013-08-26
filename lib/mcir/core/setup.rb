class Mcir::Core
  # Contain setup related stuff.
  module Setup
    # Inits the logger instance.
    # @note This method is considered private API, do not use it.
    # @private
    def init_logger
      @logger = Banana::Logger.new(:mcir)
      @logger.log "Mcir #{Mcir::VERSION} started (#{Time.now})" unless ARGV.include?("--nologger")
    end

    # Inits the configuration incl. early ARGV manipulation.
    # @note This method is considered private API, do not use it.
    # @private
    def init_config
      @config = YAML::load_file("#{MCIR_ROOT}/config.yml")
      raise "config invalid (not a hash)" unless @config.is_a?(Hash)
      @logger.disable(:debug) unless @config["mcir"]["debug"]

      # early ARGV manipulation to get --debug and --nologger
      @logger.enable(:debug) if ARGV.delete("--debug")
      @logger.disable if ARGV.delete("--nologger")

      @logger.debug "config loaded"
    rescue Exception => e
      msg = "Couldn't read config file, please check.".red
      msg << "\n\tError: #{e.message}".yellow unless e.message.blank?
      abort msg
    end

    # Inits option parser with default params
    # @note This method is considered private API, do not use it.
    # @private
    def init_opts
      @opts = OptionParser.new do |opts|
        opts.banner = "Usage: mcir [instance] action [options]"
        opts.on("-h", "--help", opts.desc_def("Show this help")) { show_help }
        opts.on("-n", "--dryrun", opts.desc_def("Commands won't be executed but printed as debug messages (with --debug)")) {
          @logger.info "Dryrun enabled (not all actions might implement it)"
          @dryrun = true
        }
        opts.on("--debug", opts.desc_def("Enables debug messages (despite config)")) {
          # see init_config early ARGV manipulation
        }
        opts.on("--nologger", opts.desc_def("Disable logger completely")) {
          # see init_config early ARGV manipulation
        }
        opts.on("----------------------------", "run actions with -h or --help to see their respective arguments here:".blue)
      end
    end

    # Registers a new action.
    #
    # @param [String, Symbol] name Name of the action.
    # @param [String, Nil] desc Description for the action (displayed in the help action overview).
    # @param [Class] klass Class to use (Mcir::Action or subclasses of it).
    # @param [Proc] handler Optional handler for the action.
    def action name, desc = nil, klass = Mcir::Action, &handler
      if desc.is_a?(Class)
        klass, desc = desc, ""
      end
      @actions[name.to_sym] = klass.new(self, name, desc, &handler)
    end

    # Loads and registers custom action classes in the actions directory.
    #
    # Each .rb file in the actions directory or it's subdirectories will be automatically loaded on
    # startup. Each class inheriting from {Mcir::Action} get's registered.
    def register_action_classes
      Dir["#{MCIR_ROOT}/actions/**/*.rb"].each { |file| require file }

      Mcir::Action.descendants.each do |klass|
        name = klass.instance_variable_get(:"@name") || klass.name.underscore
        desc = klass.instance_variable_get(:"@desc") || klass.instance_variable_get(:"@description")
        self.action(name, desc, klass)
      end
    end
  end
end
