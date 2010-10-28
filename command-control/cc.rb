#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'sequel'

unless Process.uid == 0
  puts "[FIDIUS CC] You need to be root!"
  exit 1
end

DB = Sequel.sqlite File.join(File.dirname(__FILE__), 'cc.sqlite')
unless DB.table_exists? :bots
  DB.create_table :bots do
    primary_key :id
    String :hostname
    String :ip
    DateTime :last_seen
  end
end

PID_FILE = File.join(File.dirname(__FILE__), 'cc.pid')
raise "[FIDIUS CC] Already running!" if File.exists? PID_FILE
File.open(PID_FILE, 'w+') do |f|
  f.puts Process.pid
end
%w[SIGINT SIGTERM].each do |sig|
  Signal.trap(sig) do
    puts "[FIDIUS CC] Shutdown."
    File.unlink PID_FILE rescue true
  end
end

enable :run
set :port => 80

def header title = 'FIDIUS CC Server version 0.1.0'
  "<html><head><title>#{title}</title></head><body><h1>#{title}</h1>"
end

def footer
  "</body></html>"
end

get '/info' do
  body  = header
  body << '<table>'
  body << '<tr><th>ID</th><th>Hostname</th><th>IP</th><th>seen</th></tr>'
  if DB[:bots].count > 0
    DB[:bots].each do |bot|
      body << '<tr>'
      body << "<td>#{bot[:id]}</td>"
      body << "<td>#{bot[:hostname]}</td>"
      body << "<td>#{bot[:ip]}</td>"
      body << "<td>#{bot[:last_seen]}</td>"
      body << '</tr>'
    end
  else
    body << '<tr><td colspan="5">No database entries.</td></tr>'
  end
  body << '</table>'
  body << footer
end

get '/session' do
  id = DB[:bots].insert(:hostname => '--', :ip => request.ip, :last_seen => DateTime.now)
  body  = header
  body << "Your session id is <strong>#{id}</strong>."
  body << footer
end
