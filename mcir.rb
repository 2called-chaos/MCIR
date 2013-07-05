MCIR_ROOT = File.expand_path("..", __FILE__)
require "#{MCIR_ROOT}/lib/mcir"

Mcir::Core.dispatch do |mcir|
  # loads all classes in the action folder
  mcir.register_action_classes

  # You can place actions here or if you need
  # more code you can add a custom action class.
  mcir.action :say_hello do |task|
    task.execute do |instance, args|
      mcir.log instance.screen_exec!("say Welcome everybody! We're on MCIR now...")
    end
  end

  # This somewhat advanced task lets kick you all or specific players from your server.
  # Some notes on this demonstration task:
  #   - 'mcir.opt' does some pretty evil stuff.
  #     Just set things through the task variable and you should be fine.
  #     This uses the Ruby OptionParser (google it) which has a pretty magic syntax.
  #   - The 'desc_def' method is just for colored descriptions and default values.
  #     You can screw it if you want.  =>  desc_def(desc, default = nil)
  #   - Due to Ruby's syntax (roughly... there's closures and stuff) a lot
  #     of things working here won't work in custom action classes and vice versa.
  #     If you plan somewhat complex tasks consider looking directly at the custom classes.
  mcir.action :kick, "kick specific or all players from the server" do |task|
    # This initializes your task which is usually option definition.
    # Other tasks may want to interact with your task so your default
    # settings should be defined here.
    task.prepare do
      task.config[:reason] = "Good bye!"

      # application argument options
      mcir.opt do
        on "-a", "--all", desc_def("kick all PLAYERs from the server") do |player|
          task.config[:kickall] = true
        end

        # This gives us a list so that you can specify multiple persons
        on "-p", "--players PLAYER,2nd,3rd", Array, desc_def("kicks PLAYERs from the server") do |players|
          task.config[:players] = players
        end

        # you need parentheses if you're writing it on one line
        on("-r", "--reason MSG", desc_def("specify a kick reason", task.config[:reason])) { |msg| task.config[:reason] = msg }
      end
    end

    # This is your actual task execution. You get the instance object on
    # which you can access the minecraft instance. The second argument
    # contain all remaining arguments passed to the application.
    #
    # args would be ["some", "string"] if called like 'mcir kick some string'
    task.execute do |instance, args|
      # You may want to check if the instance is running.
      # Per default it checks on :screen and :lock so it is explicit here.
      # There is also :rcon and :query but this isn't necessarily enabled.
      if !instance.online?(:lock, :screen)
        mcir.abort "Instance not running!"
      end

      if task.config[:kickall] # kick all players
        instance.screen_exec! "kickall #{task.config[:reason]}"
      elsif task.config[:players].any? # kick players from list
        task.config[:players].each do |player|
          instance.screen_exec! "kick #{player} #{task.config[:reason]}"
        end
      end
    end
  end
end
