module DrbHelper

  def get_msf_worker
    require 'drb'
    msf = YAML.load_file File.join(RAILS_ROOT, 'config', 'msf.yml')
    unless msf['drb_url']
      raise ArgumentError.new "Please specify drb_url in config/msf.yml"
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
  
  def msf_worker cmd
    system("ruby script/runner lib/fidius/starter.rb #{cmd} -e #{RAILS_ENV}")
  end
  
end
