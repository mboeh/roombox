
require 'ostruct'

module Roombox

  class Plugin
    attr_reader :name
  end

  class OutputPlugin < Plugin
    def args
      {}
    end
    
    def open(*args)

    end

    def write(buf)

    end

    def close

    end
  end

  class InputPlugin < Plugin
    def filetypes
      []
    end

    def handles?(filename)
      filetypes.each do |ex|
        if filename =~ ex then
          return true
        end
      end
      return false
    end

    def open(file)

    end
    
    def info        # For now, at least.
      OpenStruct.new
    end

    def read(bytes)

    end

    def close

    end
  end

  class FilterPlugin < Plugin

    def filter(buf)
      return buf
    end
    
  end

  class NotifyPlugin < Plugin

    def requests
      []
    end

    def notifies?(kind)
      if requests.index(kind) or requests.index(:all) then
        return true
      else
        return false
      end
    end

    def notify(kind, argh)

    end
    
  end

  class PluginError < StandardError

  end

end
