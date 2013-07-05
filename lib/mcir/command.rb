class Mcir::Command < Array
  attr_accessor :mode

  def initialize initial = [], mode = :capture, &block
    concat Array.wrap(initial)
    @mode = mode
    block.try(:call, self)
  end

  def + cmd
    self.class.new dup.concat(cmd)
  end

  def to_s
    join(" ")
  end

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

  class IO
    attr_reader :out, :err, :status

    def initialize command
      @command = command
    end

    def capture3
      @out, @err, @status = Open3.capture3(@command.to_s)
      self
    end

    def open3
      @out, @err, @status = Open3.popen3(@command.to_s)
      self
    end

    def backtick
      @out = `#{@command}`
      self
    end

    def to_s
      "executed `#{@command.to_s.ellipsisize}'"
    end
  end
end
