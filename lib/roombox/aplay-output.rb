require 'roombox/plugin'

module Roombox

  class AplayOutput < OutputPlugin
    def name
      "aplay"
    end
    
    def args
      {:command => [String]}
    end
    
    def open(argh = {})
      @command = argh[:command] || 'aplay -fcd'
      @io = IO.popen(@command, 'w')
      return true
    end

    def write(buf)
      @io.write(buf)
    end

    def close
      @io.close
      @io = nil
      @command = nil
    end
  end
end
