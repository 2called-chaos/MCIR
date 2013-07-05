
class Mcir::Shell < Mcir::Action
  @name = "shell"
  @desc = "gives you an interactive shell"

  attr_reader :instance, :args

  def setup!
    register_options
  end

  def register_options act = self
    @mcir.opt do
      on("-e", "--exec CMD", desc_def("Executes the command non-interactively")) {|c| act.config[:command] = c }
    end
  end

  def call instance, args
    @instance, @args = instance, args

    if @config[:command]
      result = eval(@config[:command])
      if @mcir.logger.enabled?
        @mcir.eachlog result.ai
      else
        puts({ result: result }.to_json)
      end
    else
      # print startup message
      @mcir.log "This is an interactive shell in the scope of an action.".blue
      @mcir.log "Visit ".blue << "pryrepl.org".magenta.underline << " to get all benefits of this shell.".blue
      @mcir.log "Type ".blue << "h".magenta << " to get more help.".blue
      @mcir.log "Type ".blue << "exit".magenta << " or ".blue << "!!!".magenta << " to end the session.".blue
      @mcir.log "Your current instance is ".blue << instance.name.magenta

      # start interactive session in the scope of an action
      self.pry

      @mcir.log "Thank you for using the interactive shell, bye..."
    end
  end

  def h ometh = nil
    meth = method(ometh.try(:to_sym)) rescue nil
    meth ||= instance.method(ometh.try(:to_sym)) rescue nil
    if ometh
      if meth
        definition = File.readlines(meth.source_location[0])[meth.source_location[1] - 1]
      else
        definition = "not found (use just 'h' to get a list of commands)"
      end
      puts "Definition: #{definition.strip}".red
    else
      puts "help yet to be written :)"

      # hint
      "Did you know that you can suppress a method's output " <<
      "by adding a semicolon to the end of your statement? " <<
      "Try it: h;"
    end
  end
end
