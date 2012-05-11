require 'roombox/plugin'
begin
  require 'xosd'
rescue
  raise Roombox::PluginError, "ruby-xosd is required to use XosdNotifer."
end

module Roombox

  class XosdNotifier < NotifyPlugin
    def initialize
      config_dir = File::join(ENV['HOME'], ".osd_buf")
      port_file = File::join(config_dir, "port")
      port = File.open(port_file).read.to_i
      DRb.start_service()
      @osd = DRbObject.new(nil, "druby://localhost:#{port}")
      @osd.puts("Roombox: xosd-notifier initialized.")
    end

    def requests
      [:all]
    end
    
    def echo(str)
      @osd.puts(str)
    end
    
    def notify(kind, argh)
      case kind
      when :playing
        filename = argh[:filename]
        info = argh[:info]
        echo("Roombox: playing #{info.artist} - #{info.title}")
      when :command
        echo("Roombox: command #{argh[:command]}")
      end
    end
  end

end
