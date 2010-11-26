module DrbHelper

  def get_msf_worker
    require 'drb'
    
    msf = YAML::parse_file File.join RAILS_ROOT, 'config', 'msf.yml'
    if not msf['drb_url']
      puts "please specify drb_url in msf.yml"
      return
    end

    # start DRb service if it hasn't been started before
    begin
      DRb.current_server
    rescue DRb::DRbServerNotFound
      DRb.start_service
      # move to different ThreadGroup to avoid mongrel hang on exit
      ThreadGroup.new.add DRb.thread
    end
    DRbObject.new nil, msf['drb_url']
  end
end
