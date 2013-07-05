class Mcir::Instance
  attr_reader :mcir, :name, :config

  def initialize mcir, name
    @mcir = mcir
    @name = name.to_s
    @config = @mcir.config["instances"][@name]
  end

  include Getters, Paths, Commands, IO, Rcon

  # --------------------------------

  def in_home &block
    old_home = Dir.getwd
    Dir.chdir(@config["home"])
    block.call
  ensure
    Dir.chdir(old_home)
  end
end
