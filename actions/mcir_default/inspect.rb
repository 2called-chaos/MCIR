class Mcir::Action::Inspect < Mcir::Action
  @name = "inspect"
  @desc = "shows information about a server"

  def setup!
    @config = { mcir: true, plist: false }
    register_options
  end

  def register_options act = self
    c = act.config
    @mcir.opt do
      on("-a", "--all", desc_def("Show everything")) { c.keys.each{|k| c[k] = true } }
      on("-n", "--none", desc_def("Show nothing")) { c.keys.each{|k| c[k] = false } }
      on("-m", "--[no-]mcir", desc_def("Show the MCIR instance config", true)) {|v| act.config[:mcir] = v }
      on("-p", "--[no-]plist", desc_def("Show the server's property list", false)) {|v| act.config[:plist] = v }
    end
  end

  def call instance, args
    @instance = instance
    if @mcir.logger.enabled?
      @mcir.log "Instance: ".yellow << "#{@instance.name}".magenta
      mcir_conf if @config[:mcir]
      server_plist if @config[:plist]
    else
      r         = { instance: @instance.name }
      r[:mcir]  = @instance.config if @config[:mcir]
      r[:plist] = @instance.properties if @config[:plist]
      puts r.to_json
    end
  end

  def server_plist
    @mcir.eachlog "Server properties".blue.underline << " = " << @instance.properties.ai
  end

  def mcir_conf
    @mcir.eachlog "MCIR configuration".blue.underline << " = " << @instance.config.ai
  end
end
