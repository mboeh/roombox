#!/usr/bin/env ruby

require 'rbconfig'
require 'fileutils'

include FileUtils

EXECUTABLES = ['roombox', 'roomboxctl']
LIBRARIES = ['lib/roombox']

def usage
  $stderr.puts <<-"EOM"
usage:
   #$0 system [bindir [libdir]]
     or
   #$0 user bindir libdir
  EOM
  exit 1
end

if ARGV.length > 0 then
  action = ARGV[0]
  if action == 'system' then
    bindir = ARGV[1] || '/usr/local/bin'
    libdir = ARGV[2] || Config::CONFIG['sitelibdir']
  elsif action == 'user' then
    bindir = ARGV[1] or usage
    libdir = ARGV[2] or usage
  else
    usage
  end

  puts <<-"EOD"
This is the installation script for Roombox.

You wish to install in the following directories:
  Binaries in #{bindir}
  Libraries in #{libdir}
EOD
  print "Is that right? [y/N] "
  $stdout.flush
  resp = $stdin.gets
  if resp =~ /y/i then
    puts "All right then. Installing..."
    begin
      EXECUTABLES.each do |exe|
        puts "* #{exe} -> #{bindir}/#{exe}"
        cp(exe, bindir)
      end
      LIBRARIES.each do |lib|
        puts "* #{lib} -> #{libdir}/#{lib}"
        cp_r(lib, libdir)
      end
      puts "All done. Have fun. Exiting."
    rescue => err
      puts "Oops! An error occurred during installation."
      puts "The error was:"
      puts "\t#{err.class}: #{err.message}"
      puts "Exiting."
    end
  else
    puts "All right then. Exiting."
  end
else
  usage
end
