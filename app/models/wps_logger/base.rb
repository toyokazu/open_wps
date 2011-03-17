class WpsLogger::Base < ActiveRecord::Base
  establish_connection :wps_logger
end
