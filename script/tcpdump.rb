class TcpDumper

  PID_FILE = File.join RAILS_ROOT, 'tmp', 'pids', 'tcp_dumper'
  OUTPUT_FILE = ARGV[2]
  IFACE = ARGV[1]

  def self.start
    puts "starting tcpdumper"
    if File.exist? PID_FILE
      begin
        pid = File.read(PID_FILE).to_i         
        Process.getpgid pid
        puts "tcpdumper already running as Process #{pid}"
        return
      rescue
        File.delete PID_FILE
        puts "No process. Deleted PID file and starting..."
      end
    end    
    File.open(PID_FILE, 'w') do |f|
      f.puts Process.pid
    end
    c = "sudo tcpdump -i #{IFACE} -w #{OUTPUT_FILE}"
    puts c
    exec c

  end

  def self.stop
    puts "stopping tcpdumper"
    begin
      pid = File.read(PID_FILE).to_i         
      Process.kill("TERM",pid.to_i)
      File.delete PID_FILE if File.exist? PID_FILE
    rescue
      puts "No process.#{$!}"
    end
  end

  def self.restart
    puts "restarting tcpdumper"
    stop
    start
  end
end
raise "Must run as root" unless Process.uid == 0
raise "No Iface set" unless ARGV[1].to_s != ""
raise "No logfile specified" unless ARGV[2].to_s != "" && ARGV[2].to_s != "-e"

TcpDumper.send ARGV[0].to_sym
