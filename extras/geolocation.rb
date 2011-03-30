module Geolocation
  class WifiTower
    class << self
      def parse(params)
        wifi_logs = []
        wifi_towers = JSON.parse(params["wifi_towers"])
        wifi_towers.each do |wifi_tower|
          wifi_access_point = WifiAccessPoint.find_or_initialize_by_json(wifi_tower)
          next if !wifi_access_point.persisted? || wifi_access_point.manual_location.nil?
          wifi_log = WifiLog.new_by_json(wifi_tower)
          wifi_log.wifi_access_point = wifi_access_point
          wifi_logs << wifi_log
        end
        wifi_logs
      end
    end
  end
end
