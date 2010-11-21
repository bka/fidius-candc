class Prelude::Connection < ActiveRecord::Base
  establish_connection PRELUDE_DB_CONFIG_NAME
end
