class Mcir::Instance
  module IO
    # read and parse the property file
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

    # return a handle to the server logfile and optionally tail on it
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

    # check if the lockfile exists
    def lockfile?
      File.exists?(lockfile_file)
    end
  end
end
