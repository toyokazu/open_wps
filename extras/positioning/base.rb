module Positioning
  class Base
    include WifiProperty
    include Coordinate

    class << self
    end

    attr_reader :options, :wifi_logs

    # Options are:
    # * <tt>:wifi_logs</tt> - Specifies an array of WifiLog observed at current location
    # * <tt>:map</tt> - Specifies a map object
    #
    def initialize(options = {})
      @wifi_logs = options[:wifi_logs]
      @map = options[:map]
    end

    # Estimate a location from wifi_logs on the specified map.
    # The estimation result is expressed by 2D pixel coordinate on
    # a specified map object and height in the map.
    # This method is just for evaluation.
    # 
    # Examples:
    # Extimate a position of a MovementLog (movement_log) on a map (map) for an evaluation
    # 
    # initialize by both <tt>:wifi_logs</tt> and <tt>:map</tt>
    #   wa = Positioning::WeightedAverage.new(:wifi_logs => movement_log.wifi_logs.where('wifi_access_points.manual_location_id IS NOT NULL').where('manual_locations.map_id = ?', map.id).all(:include => {:wifi_access_point => :manual_location}), :map => map)
    #   wa.estimate_by_map
    #
    def estimate_by_map
    end

    # Estimate a location from wifi_logs
    # The estimation result is expressed by 3D geometry object.
    # 
    # Options are:
    # * <tt>:wifi_logs</tt> - Specifies an array of WifiLog observed at current location
    #
    # Examples:
    # Extimate a position of a MovementLog (movement_log) for an evaluation
    #
    # initialize by <tt>:wifi_logs</tt>
    #   wa = Positioning::WeightedAverage.new(:wifi_logs => movement_log.wifi_logs.where('wifi_access_points.manual_location_id IS NOT NULL').all(:include => {:wifi_access_point => :manual_location}))
    #   wa.estimate_by_geom
    # 
    # Estimate a position with WiFi observation data
    # 
    #   wa = Positioning::WeightedAverage.new(:wifi_logs => Geolocation::WifiTower.parse(params))
    #   wa.estimate_by_geom
    # 
    # Other algorithm example:
    #   wa = Positioning::Triangulation.new(:wifi_logs => movement_log.wifi_logs.where('wifi_access_points.manual_location_id IS NOT NULL').all(:include => {:wifi_access_point => :manual_location}))
    # 
    def estimate_by_geom
    end
  end
end
