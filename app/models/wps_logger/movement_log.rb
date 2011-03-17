class WpsLogger::MovementLog < WpsLogger::Base
  set_table_name :movement_logs

  belongs_to :gps_location
  belongs_to :manual_location
  belongs_to :user
  has_many :wifi_logs
end
