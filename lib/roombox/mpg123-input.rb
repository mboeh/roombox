require 'roombox/plugin'
begin
  require 'mp3tag'
  HAS_MP3_TAG = true
rescue LoadError
  HAS_MP3_TAG = false
end

begin
  IO.popen("mpg123 -v 2>&1")
rescue
  raise Roombox::PluginError, "The mpg123 program is required to use Mpg123Input."
end

module Roombox

  class Mpg123Input < InputPlugin
    
    def name
      "mpg123"
    end

    def filetypes
      [/\.mp3$/]
    end

    def open(file)
      @filename = file
      @io = IO.popen("mpg123 -s '#{file}'", 'r')
    end

    def info
      struct = OpenStruct.new
      if HAS_MP3_TAG and @filename then
        tag = Mp3Tag.new(@filename)
        struct.artist = tag.artist
        struct.title = tag.title
        struct.album = tag.album
        struct.bitrate = tag.bitrate
      end
      return struct
    end
    
    def read(bytes)
      if @io then
        @io.read(bytes)
      else
        nil
      end
    end
    
    def close
      if @filename and @io then
        @io.close
        @io = nil
        @filename = nil
      end
    end

  end
end
