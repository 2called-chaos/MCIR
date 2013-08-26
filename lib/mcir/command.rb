module Mcir
  # Wrapper class for commands to easier handle them. Especially useful for lazy execution.
  class Command < Array
    attr_accessor :mode

    # Initializes a new command object. The mode defines the
    # execution method of the command which are:
    #
    #   * :backticks => Kernel's #`` (in shell session)
    #   * :capture => Open3's #catpure3 (subshell)
    #   * :open => Open3's #open3 (subshell)
    #   * :exec => Kernel's #exec (process replace)
    #
    # @param [String, Array, Mcir::Command] initial Initial command
    # @param [Symbol] mode The execution mode to use
    # @param [Proc] block Optional block to setup command
    # @yieldparam cmd [Mcir::Command] self
    def initialize initial = [], mode = :capture, &block
      concat Array.wrap(initial)
      @mode = mode
      block.try(:call, self)
    end

    # Concatenates array or Mcir::Command to self.
    #
    # @param [Array, Mcir::Command] cmd Command to add.
    def + cmd
      self.class.new dup.concat(cmd)
    end

    # Returns the actual command as string.
    def to_s
      join(" ")
    end

    # Executes the command unless application is in dryrun mode.
    #
    # @note If the application is running in dryrun mode this method just returns a string!
    # @return [Mcir::Command::IO] Command result object
    def execute!
      if Mcir::Core.instance.dryrun?
        Mcir::Core.instance.debug("CMD: ".purple << "#{self.to_s.gsub("\r", "")}")
        "skipped execution due to dryrun"
      else
        case @mode
          when :exec      then exec(self.to_s)
          when :open      then IO.new(self).open3
          when :capture   then IO.new(self).capture3
          when :backticks then IO.new(self).backtick
        end
      end
    end

    # Command execution result object.
    #
    # For the mode `open3` and `capture3` you will get 3 accessors for the result `out`, `err`, `status`.
    # For the mode `backticks` you just get `out` the other both are nil.
    class IO
      attr_reader :out, :err, :status

      # Initializes a new result object
      def initialize command
        @command = command
      end

      # Executes the command with Open3's capture3
      def capture3
        @out, @err, @status = Open3.capture3(@command.to_s)
        self
      end

      # Executes the command with Open3's open3
      def open3
        @out, @err, @status = Open3.popen3(@command.to_s)
        self
      end

      # Executes the command with Kernel's backticks.
      def backtick
        @out = `#{@command}`
        self
      end

      # To string coersion for log output.
      def to_s
        "executed `#{@command.to_s.ellipsisize}'"
      end
    end
  end
end
