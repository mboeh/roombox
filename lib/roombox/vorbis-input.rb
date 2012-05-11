require 'roombox/plugin'

begin
  require 'vorbisfile'
rescue LoadError
  raise Roombox::PluginError, "Ruby-VorbisFile is required to use VorbisInput."
end

module Roombox

  class VorbisInput < InputPlugin
    def initialize
      @vf = Ogg::VorbisFile.new
    end
    
    def name
      "ogg-vorbis"
    end

    def filetypes
      [/\.ogg$/]
    end

    def open(file)
      if file.kind_of?(IO) then
        if @vf.open(file) then
          @opened = true
        else
          @opened = false
        end
      elsif file.respond_to?(:to_str) then
        if @vf.open(File.open(file.to_str)) then
          @opened = true
        else
          @opened = false
        end
      end
    end

    def opened?
      @opened
    end
    
    def info
      struct = OpenStruct.new
      if opened? then
        comments = @vf.comments(-1)
        struct.artist = comments['artist']
        struct.title = comments['title']
        struct.album = comments['album']
      end
      return struct
    end
    
    def read(bytes)
      buf = ""
      if @vf.read(buf, bytes, false, 2, true) then
        buf
      else
        nil
      end
    end
    
    def close
      if opened? then
        @vf.close
        @opened = false
      end
    end

  end
end
