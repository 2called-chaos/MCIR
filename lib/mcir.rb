module Mcir
  # sync output
  STDOUT.sync = true

  # init dependencies
  Bundler.require

  # core dependencies
  require "singleton"
  require "open3"
  require "yaml"
  require "optparse"
  require "timeout"
  require "shellwords"
  require "active_support/core_ext/object"
  require "active_support/core_ext/string/inflections"
  require "active_support/core_ext/string/filters"
  require "active_support/core_ext/hash/except"
  require "active_support/core_ext/hash/slice"

  # application
  "#{MCIR_ROOT}/lib/mcir".tap do |lib|
    require "#{lib}/version"
    require "#{lib}/command"
    require "#{lib}/instance/getters"
    require "#{lib}/instance/paths"
    require "#{lib}/instance/io"
    require "#{lib}/instance/commands"
    require "#{lib}/instance/server_log"
    require "#{lib}/instance/rcon"
    require "#{lib}/instance"
    require "#{lib}/action"
    require "#{lib}/logger"
    require "#{lib}/core/support"
    require "#{lib}/core/helper"
    require "#{lib}/core/getters"
    require "#{lib}/core/setup"
    require "#{lib}/core/dispatch"
    require "#{lib}/core"
  end
end
