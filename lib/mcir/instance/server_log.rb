class Mcir::Instance
  class ServerLog < File
    include File::Tail
  end
end
