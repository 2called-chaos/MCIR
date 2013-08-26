class String
  # Improved string truncation (truncate from the middle).
  #
  # @param [Integer] ledge String length on left side
  # @param [Integer] redge String length on right side
  def ellipsisize(ledge=10,redge=ledge*2)
    return self if self.length < ledge+redge
    sledge = '.'*ledge
    sredge = '.'*redge
    mid_length = self.length - ledge - redge
    gsub(/(#{sledge}).{#{mid_length},}(#{sredge})/, '\1...\2')
  end
end

class OptionParser
  # Helper to colorize OptionParser description strings.
  #
  # @param [String] desc The actual description text (colored in yellow)
  # @param default Default value for this option (colored in blue, everything except nil)
  # @return [String] Colorized string.
  def desc_def desc, default = nil
    desc = desc.yellow
    unless default.nil?
      desc << " (def: ".yellow << default.to_s.magenta << ")".yellow
    end
    desc
  end
end
