#!/usr/bin/env ruby

require 'thin'
require 'rack'
require 'yaml'
require 'fileutils'
require 'pp' # pretty print things, e.g. `pp ENV`

require File.join(File.dirname(__FILE__), 'lib', 'cc-interface.rb')
require File.join(File.dirname(__FILE__), 'lib', 'cc-servlet.rb')

module CommandControl
  PID_FILE = File.join(File.dirname(__FILE__), 'cc.pid')
  def boot
    config = YAML.load_file File.join(File.dirname(__FILE__), 'cc.yaml')
    puts "Starting #{CommandControl::Servlet.signature}"
    if File.exists? PID_FILE
      puts "There is aready an instance running (pid #{File.read(PID_FILE).strip})"
      return
    end
    puts "Process id: #{Process.pid}"
    File.open(PID_FILE, 'w+') do |f|
      f.write Process.pid
    end
    Thin::Server.start '0.0.0.0', config["port"], CommandControl::Servlet.new
    FileUtils.rm_f PID_FILE
  end
  module_function :boot
end

