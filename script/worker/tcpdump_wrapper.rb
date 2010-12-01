require 'pcaprub'
require 'rex'
require 'racket'

class TcpDumpWrapper
  EXEC_STATUS_INIT = 1
  EXEC_STATUS_STARTED = 2  
  EXEC_STATUS_STOPPED = 3
  
  def initialize(iface)
    @exec_status = EXEC_STATUS_INIT
    @iface = iface
    @pcap_file = File.join "#{RAILS_ROOT}","tmp","dump.pcap"

    raise Exception.new("TcpDumper can only be used as root.") unless Process.uid == 0
  end

  def start
    raise Exception.new("Can not start until last log was read.") if @exec_status != EXEC_STATUS_INIT 
    system("ruby script/runner script/tcp_dumper start #{@iface} #{@pcap_file}")
    @exec_status = EXEC_STATUS_STARTED
  end

  def stop
    # nicht stoppen vor start
    raise Exception.new("Can not stop until dumping was started.") if @exec_status != EXEC_STATUS_STARTED 
    system("ruby script/runner script/tcp_dumper stop")
    @exec_status = EXEC_STATUS_STOPPED
  end

  def read(&block)
    # nicht lesen bevor stop
    raise Exception.new("Can not read until dumping was stopped") if @exec_status != EXEC_STATUS_STOPPED

    a = ::Pcap.open_offline(@pcap_file)
    a.each do |raw|
	    eth = Racket::L2::Ethernet.new(raw)
      if eth.ethertype == 0x0800
        ip = Racket::L3::IPv4.new(eth.payload)
        if ip.protocol == 6
          tcp = Racket::L4::TCP.new(ip.payload)
          block.call ip.src_ip,tcp.src_port,ip.dst_ip,tcp.dst_port,tcp.payload
        end
      end
    end

    # nach dem lesen löschen    
    # erstmal noch nich File.unlink(@pcap_file) if File.exist? @pcap_file
    @exec_status = EXEC_STATUS_INIT
  end
end
