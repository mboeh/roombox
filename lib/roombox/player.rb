require 'roombox/plugin'
require 'thread'
require 'drb'

class Array
  def index_find(re)
    each_index do |idx|
      if self[idx] =~ re then
        return idx
      end
    end
    return nil
  end
end

module Roombox

  class Player
    attr_reader :playlist
    attr_reader :outputs
    attr_reader :inputs
    attr_reader :filters
    attr_reader :notifiers
    attr_reader :plock
    attr_reader :current
    attr_reader :player_thread

    def initialize(plist = [])
      @outputs = []
      @inputs  = []
      @filters = []
      @notifiers = []
      @commands = []
      @curr_output = nil
      #@plock = Mutex.new
      @playlist = []
      @position = nil
      queue(plist)
    end

    def queue(list)
      #plock.synchronize do
        if list.kind_of?(String) then
          flz = Dir[list.sub(/^~/, ENV['HOME'])]
          playlist.push(*flz)
        else
          playlist.push(*list)
        end
      #end
    end

    def unqueue(list)
      #plock.synchronize do
        list.each do |item|
          playlist.delete(item)
        end
      #end
    end

    def select_output(name)
      @outputs.each do |oput|
        if oput.name == name then
          @curr_output = oput
        end
      end
    end

    def find_input(filename)
      @inputs.each do |iput|
        if iput.handles?(filename) then
          return iput
        end
      end
      return nil
    end
    
    def do_filters(buf)
      @filters.each do |filt|
        buf = @filters.filter(buf)
      end
      return buf
    end

    def notify(kind, argh)
      notifiers.each do |nfi|
        if nfi.notifies?(kind) then
          nfi.notify(kind, argh)
        end
      end
    end
    
    def play
      Thread.abort_on_exception = true
      @player_thread = Thread.new do
        catch(:cessate) do
          @position = 0

          @curr_output.open
          while 1 do
            catch(:proceed) do
              check_command
              file = playlist[@position] or throw :cessate
              if input = find_input(file) and @curr_output then
                if !input.open(file) then
                  raise "balls"
                end
                begin
                  @current = input.info
                  if not @current then
                    raise "WTF!"
                  end
                  notify(:playing, {
                    :filename => file,
                    :info     => @current
                  })
                  while buf = input.read(4096) do
                    check_command
                    buf = do_filters(buf)
                    @curr_output.write(buf)
                  end
                rescue
                  raise
                ensure
                  input.close
                end
              end
              @position += 1
            end 
          end
          @curr_output.close
        end
        @position = nil
      end
    end

    def check_command
      while command = next_command do
        notify(:command, {
          :command => command[0],
          :args    => command[1,-1]
        })
        case command[0]
        when :stop
          throw :cessate
        when :pause
          Thread.stop
        when :next
          @position += 1
          throw :proceed
        when :prev
          @position -= 1
          throw :proceed
        when :jump
          if command[1].kind_of?(String) then
            if pos = command.index_find(/#{command[1]}/) then
              @position = pos
              throw :proceed
            end
          elsif command[1].kind_of?(Integer) then
            if command[1] < playlist.length then
              @position = command[1]
              throw :proceed
            end
          end
        when :sort
          # Field is ignored for now. Playlists aren't preloaded yet anyway.
          filename = playlist[@position]
          if command[2] then
            # Ascending sort
            playlist.sort! do |a,b| a <=> b end
          else
            # Descending sort
            playlist.sort! do |a,b| b <=> a end
          end
          # Now stand in the place where we live.
          @position = playlist.index(filename)
        end
      end
    end
    def push_command(command, *args)
      @commands.push([command, *args])
    end

    def next_command
      @commands.shift
    end
  
    def pause
      push_command(:pause)
    end

    def unpause
      if @player_thread.status == "sleep" then
        @player_thread.run
      end
    end
    
    def stop
      push_command(:stop)
    end
 
    def next
      push_command(:next)
    end

    def prev
      push_command(:prev)
    end

    def jump(to)
      push_command(:jump, to)
    end

    def version
      "Roombox 0.9.0"
    end
    
    def shutdown
      DRb::stop_service
      exit
    end

    def status
      if @player_thread then
        if @player_thread.status == "sleep" then
          "paused"
        else
          "playing"
        end
      else
        "stopped"
      end
    end

    def current_index
      @position
    end

    def current_file
      playlist[@position]
    end

    def next_file
      playlist[@position + 1]
    end

    def prev_file
      playlist[@position - 1]
    end
    
    def index_of_file(str)
      playlist.index_find(/#{str}/)
    end

    def sort(field, ascending = true)
      push_command(:sort, field, ascending)
    end

    def shut_up
      $stdout.close
      $stderr.close
    end
  end
end
