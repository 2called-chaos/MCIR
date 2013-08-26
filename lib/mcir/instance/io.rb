class Mcir::Instance
  # Contains IO operations for instances.
  module IO
    # Reads and parses the property file of the instance. It will attempt to make same basic type
    # conversions. It will detect booleans and integers.
    #
    # @param [Boolean] reload If set to true the cache will be wiped and reloaded from disk.
    # @return [Hash] Hash of the server properties.
    def properties reload = false
      @_properties = nil if reload
      @_properties ||= begin
        if File.exist?(properties_path)
          {}.tap do |result|
            File.open(properties_path).each_line do |line|
              next if line.strip.start_with?("#")
              chunks = line.split("=")
              key    = chunks.shift
              v      = chunks.join("=").strip.presence

              # convert to proper types
              v = v.to_i if v =~ /\A[0-9]+\Z/ # integer
              v = true if v == "true"
              v = false if v == "false"

              result[key] = v
            end
          end
        end
      end
    end

    # Returns a handle to the server logfile and optionally tail on it.
    #
    # @option opts [Boolean] tail (false) Tail the server log
    # @option opts [Integer] interval (1) Tail interval
    # @option opts [Integer] n (0) Backlog in lines
    # @option opts [Boolean] f (false) Follow file (tail -f)
    # @option opts [Boolean] whiny (false) Raise exceptions on EOF if set to true
    # @option opts [String] mode ("r") File open mode
    # @param [Proc] block Block to send to tail (only needed when tail is set to true)
    def logfile opts = {}, &block
      opts = { tail: false, interval: 1, n: 0, f: false, whiny: false, mode: "r" }.merge(opts)
      if File.exist?(logfile_path)
        ServerLog.open(logfile_path, opts[:mode]).tap do |log|
          if opts[:tail]
            log.interval      = opts[:interval]
            log.return_if_eof = !opts[:f] && !opts[:whiny]
            log.break_if_eof  = !opts[:f] && opts[:whiny]
            log.backward(opts[:n])
            return log.tail(&block)
          end
        end
      end
    end

    # Checks whether the lockfile exists.
    #
    # @return [Boolean] true if the lockfile exists.
    def lockfile?
      File.exists?(lockfile_file)
    end
  end
end
