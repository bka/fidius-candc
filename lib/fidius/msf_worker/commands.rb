class FIDIUS::MsfWorker
  # Loads the predefined commands using register_command.
  # @return nil
  def load_commands
    ['command_pool', 'autopwn'].each do |f|
      require "fidius/msf_worker/commands/#{f}"
    end
    nil
  end
  
  # With this helper method you may define a command method by typing:
  # 
  #  FIDIUS::MsfWorker.register_command :foo do |options|
  #    p options
  #  end
  #
  # Later, you might call +cmd_foo+ (note the +cmd_+ prefix) with an
  # +options+ hash, like
  #
  #  w = FIDIUS::MsfWorker.new
  #  w.cmd_foo :lhost=>'127.0.0.1', :args=>[1,2,3]
  # 
  # which will then trigger the
  #
  #  p { :lhost => '127.0.0.1', :args => [1,2,3] }
  #
  # line. (Insert useful code on your own.)
  #
  # @param [Symbol, String] command  May be arbritary but conform to
  #        method names and unique.
  # @param [Proc] block  Will be executed in the context of the
  #        {FIDIUS::MsfWorker} class.
  # @return [Boolean]  false if the +command+ was already registered,
  #         or true if not.
  def self.register_command command, &block
    command = "cmd_#{command}".to_sym
    @@commands ||= []
    return false if @@commands.include? command
    @@commands << command
    send :define_method, command, &block
    true
  end
end
