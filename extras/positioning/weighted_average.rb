module Positioning
  # rekimoto method
  class WeightedAverage < Positioning::Base
    class << self # class methods
    end # class methods

    def initialize(options = {})
      super(options)
      @options = {
      }.merge(options)
    end

    def estimate_by_map
      x = 0
      y = 0
      z = 0
      dist_sum = 0.0
      @wifi_logs.each do |wifi_log|
        x += wifi_log.wifi_access_point.manual_location.x / Base.dist_value(wifi_log.signal)
        y += wifi_log.wifi_access_point.manual_location.y / Base.dist_value(wifi_log.signal)
        z += (wifi_log.wifi_access_point.manual_location.height + wifi_log.wifi_access_point.manual_location.map.o_alt) / Base.dist_value(wifi_log.signal)
        dist_sum += 1 / Base.dist_value(wifi_log.signal)
      end
      [(x / dist_sum), (y / dist_sum), (z / dist_sum) - @map.o_alt]
    end

    def estimate_by_geom
      avg_geom = Point.from_lon_lat_z(0.0, 0.0, 0.0, Base::SRID)
      dist_sum = 0.0
      @wifi_logs.each do |wifi_log|
        avg_geom.x += wifi_log.wifi_access_point.manual_location.geom.lon / Base.dist_value(wifi_log.signal)
        avg_geom.y += wifi_log.wifi_access_point.manual_location.geom.lat / Base.dist_value(wifi_log.signal)
        avg_geom.z += wifi_log.wifi_access_point.manual_location.geom.z / Base.dist_value(wifi_log.signal)
        dist_sum += 1 / Base.dist_value(wifi_log.signal)
      end
      avg_geom = Point.from_lon_lat_z(avg_geom.lon / dist_sum, avg_geom.lat / dist_sum, avg_geom.z / dist_sum, Base::SRID)
    end

    # FIXME
    def estimate_by_sql(options = {})
      target = options[:movement_log]
      geom = "manual_locations.geom"
      dist = Base.dist
      calc = "sum((x(#{geom})) / #{dist}) / sum(1 / #{dist}), sum((y(#{geom})) / #{dist}) / sum(1 / #{dist}), sum((z(#{geom})) / #{dist}) / sum(1 / #{dist})"
      Point.from_hex_ewkb(MovementLog.calculate(:st_makepoint, calc, {:include => {:wifi_logs => {:wifi_access_points => :manual_locations}}, :conditions => ['movement_logs.id = ? and .geom IS NOT NULL', target.id]}))
    end
  end
end

