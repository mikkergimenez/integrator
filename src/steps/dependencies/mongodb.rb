
def is_port_open?(ip, port)
  begin
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(ip, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
    rescue Timeout::Error
  end

  return false
end


module TestDependencies
  class MongoDB
    def self.check runner
      if is_port_open?('127.0.0.1', 27017) and `ps aux | grep mongo[d]` != ""
        return true, "The required dependency MongoDB is running"
      else
        return false, "The required dependency MongoDB is not running"
      end
    end
  end
end
