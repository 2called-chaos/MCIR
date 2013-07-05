class Mcir::Core
  module Setup
    # init the logger
    def init_logger
      @logger = Banana::Logger.new(:mcir)
      @logger.log "Mcir #{Mcir::VERSION} started (#{Time.now})" unless ARGV.include?("--nologger")
    end

    # init the configuration incl. early ARGV manipulation
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

    # init option parser with default params
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

    # registers a new action
    def action name, desc = nil, klass = Mcir::Action, &handler
      if desc.is_a?(Class)
        klass, desc = desc, ""
      end
      @actions[name.to_sym] = klass.new(self, name, desc, &handler)
    end

    # loads and registers custom action classes
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
