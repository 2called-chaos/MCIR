class Mcir::Instance
  # Custom file class with File::Tail.
  class ServerLog < File
    include File::Tail
  end
end
