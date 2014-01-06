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
      if !@config && @name.present? && @mcir.config["mcir"]["instance_autocomplete"]
        avail_keys = @mcir.config["instances"].keys
        @name.to_s.split(".").each do |qchunk|
          avail_keys = avail_keys.grep(/#{Regexp.escape(qchunk)}/)
        end
        case avail_keys.length
        when 1
          apply avail_keys.first
          @mcir.log "autodiscovered instance " << "#{@name}".magenta << " from input ".yellow << "#{name}".magenta
        when 0
          raise ArgumentError, "instance `#{@name}' can't be resolved, does not exist (#{@mcir.config["instances"].keys})"
        else
          raise ArgumentError, "ambiguous instance name `#{@name}' matching #{avail_keys}"
        end
      end

      # guess instance from pwd
      if !@config && @name.blank? && @mcir.config["mcir"]["instance_cwd_guessing"]
        avail_homes = @mcir.config["instances"].map{|k,v| [k, v["home"]] }
        matching_homes = avail_homes.select{|_,h| h.start_with?(ENV["PWD"]) }
        matching_homes += avail_homes.select{|_,h| h.start_with?(ENV["OLDPWD"]) }
        matching_homes.uniq!
        if matching_homes.length == 1
          apply matching_homes[0][0]
          @mcir.log "autodiscovered instance " << "#{@name}".magenta << " from working directory ".yellow <<  "#{matching_homes[0][1]}".magenta
        end
      end

      # use default instance
      if !@config
        apply @mcir.config["mcir"]["default_instance"]
        @mcir.log "using default instance " << "#{@name}".magenta
      end
    end

    # Applies name and config (shortcut for setup)
    def apply name
      @name = name
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
