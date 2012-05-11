require 'roombox/plugin'
begin
  require 'audiooutput'
rescue LoadError
  raise Roombox::PluginError, "Ruby-AudioOutput is required to use AoOutput."
end

module Roombox

  class AoOutput < OutputPlugin
    def name
      "ao"
    end

    def args
      {}
    end

    def open(argh = {})
      @ao = AudioOutput.new
      @dtype = AudioOutput::driver_info(AudioOutput::default_driver_id)['type']
      # Assuming type is live for now
      if !@ao.open_live(
        AudioOutput::default_driver_id, 16, 44100, 2, 0) then
        return false
      end
      return true
    end

    def write(buf)
      @ao.play(buf)
    end
    
    def close
      @ao.close
    end
  end

end
