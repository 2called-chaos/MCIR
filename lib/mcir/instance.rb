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
