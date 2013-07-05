class Mcir::Instance
  module Paths
    def distinct_relative_path file
      file.to_s.start_with?("/", "~/") ? file : "#{@config["home"]}/#{file}"
    end

    def logfile_path
      distinct_relative_path @config["server_log"]
    end

    def properties_path
      distinct_relative_path @config["server_plist"]
    end

    def lockfile_file
      "#{logfile_path}.lck"
    end
  end
end
