class Mcir::Instance
  # Contains getters for file paths.
  module Paths
    # Distincts whether a path is relative or not and prepending the instance's home path if not.
    # @return [String]
    def distinct_relative_path file
      file.to_s.start_with?("/", "~/") ? file : "#{@config["home"]}/#{file}"
    end

    # Returns the logfile path.
    # @return [String]
    def logfile_path
      distinct_relative_path @config["server_log"]
    end

    # Returns the plist path.
    # @return [String]
    def properties_path
      distinct_relative_path @config["server_plist"]
    end

    # Returns the lockfile path.
    # @return [String]
    def lockfile_file
      "#{logfile_path}.lck"
    end
  end
end
