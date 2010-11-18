
module ActionView
  class Base
    # Die models von MSF liegen im Namespace Msf::DBManager,
    # sodass Rails versucht diese methode zu finden, wenn man 
    # auf ein HostsObjekt url_for aufruft, allerdings definiert
    # sich diese methode nicht, weil die models ja außerhalb in MSF liegen
    # ==
    # sehr hässlich, geht das nicht irgendwie generisch?
    def msf_db_manager_host_path *args
      host_path(*args)
    end
  end
end
module MsfHelper
end