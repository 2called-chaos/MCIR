class String
  def ellipsisize(ledge=10,redge=ledge*2)
    return self if self.length < ledge+redge
    sledge = '.'*ledge
    sredge = '.'*redge
    mid_length = self.length - ledge - redge
    gsub(/(#{sledge}).{#{mid_length},}(#{sredge})/, '\1...\2')
  end
end

class OptionParser
  def desc_def desc, default = nil
    desc = desc.yellow
    unless default.nil?
      desc << " (def: ".yellow << default.to_s.magenta << ")".yellow
    end
    desc
  end
end
