module Mcir
  # Instance representing your server (or whatever resource).
  class Instance
    attr_reader :mcir, :name, :config

    # Initializes a new instance object.
    # @param [Mcir::Core] mcir MCIR instance
    # @param [String, Symbol] name Name of the instance (in config).
    def initialize mcir, name
      @mcir = mcir
      @name = name.to_s.dup
      @config = @mcir.config["instances"][@name]

      # autocomplete configuration name
      if !@config && @name.present?
        avail_keys = @mcir.config["instances"].keys
        @name.to_s.split(".").each do |qchunk|
          avail_keys = avail_keys.grep(/#{Regexp.escape(qchunk)}/)
        end
        case avail_keys.length
        when 1
          @name = avail_keys.first
          @config = @mcir.config["instances"][@name]
          @mcir.debug "autodiscovered instance `#{@name}' from input `#{name}'"
        when 0
          raise ArgumentError, "instance `#{@name}' can't be resolved, does not exist (#{@mcir.config["instances"].keys})"
        else
          raise ArgumentError, "ambiguous instance name `#{@name}' matching #{avail_keys}"
        end
      end
    end

    include Getters, Paths, Commands, IO, Rcon

    # --------------------------------

    # Helper to call the block in the instance's home directory.
    #
    # @param [Proc] block Block to execute with the instance's home directory as `pwd`.
    def in_home &block
      old_home = Dir.getwd
      Dir.chdir(@config["home"])
      block.call
    ensure
      Dir.chdir(old_home)
    end
  end
end
