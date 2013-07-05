class Mcir::Action
  attr_reader :mcir, :desc, :config
  alias_method :description, :desc

  def name
    @name.to_s
  end

  # =========
  # = setup =
  # =========
  def initialize mcir, name, desc = nil, &block
    @mcir = mcir
    @name = name
    @desc = desc
    @config = {}
    setup(&block)
  end

  def setup &block
    block.try(:call, self)
  end

  def prepare &block
    @preparator = block
  end

  def execute &block
    @executor = block
  end

  # =====================
  # = track descendants =
  # =====================
  def self.descendants
    @descendants ||= []
  end

  def self.inherited(descendant)
    descendants << descendant
  end

  # =============
  # = execution =
  # =============
  def setup!
    @preparator.try(:call)
  end

  def call *a
    @executor.try(:call, *a)
  end

  def prefix
    "".tap do |o|
      o << "  " if @mcir.logger.debug?
      o << "[#{name}] ".purple
    end
  end
end
