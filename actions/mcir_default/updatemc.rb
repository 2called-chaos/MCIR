# We pull the jar from the URL specified and place it into the server directory. When the name of the jar is not minecraft_server.jar we will symlink it.
# This way you can easily pull snapshots without the need to change the config all the time.
class Mcir::Action::Updatemc < Mcir::Action
  @name = "updatemc"
  @desc = "Download the jar from the URL specified and symlink it to minecraft_server.jar and restarts the server"

  def setup!
    @config = { url: nil, symlink: "minecraft_server.jar", restart: false }
    register_options
  end

  def register_options act = self
    @mcir.opt do
      on("-u", "--url URL", String, desc_def("Direct URL to the jar file")) {|n| act.config[:url] = n }
      on("-r", "--restart", desc_def("Restart the server after updating the jar", false)) {|n| act.config[:restart] = true }
      on("-s", "--symlink FILENAME", String, desc_def("the name of the symlink", "minecraft_server.jar")) {|n| act.config[:symlink] = n }
    end
  end

  def call instance, args
    @instance = instance

    @instance.in_home do
      @mcir.log "  Instance: ".yellow << "#{@instance.name}".magenta
      @mcir.log "JAR source: ".yellow << "#{@config[:url].presence || "<undefined>".red}".magenta

      if !@config[:url].present?
        @mcir.abort "You have to pass a download URL with -u or --url", code: 1
      end

      # download
      system(%{curl -O "#{@config[:url]}"})

      # symlink
      if @config[:symlink].present? && File.basename(@config[:url]) != "minecraft_server.jar"
        begin
          FileUtils.ln_s(File.basename(@config[:url]), "minecraft_server.jar", force: true)
        rescue
          @mcir.warn "Failed to create symlink: #{$!.message}"
        end
      end

      # restart
      if @config[:restart]
        @mcir.prepare_action("restart")
        @mcir.get_action("stop").instance_eval do
          @config[:message] = "Restarting the server due to update!"
        end
        @mcir.dispatch_action("restart")
      end
    end
  end
end
