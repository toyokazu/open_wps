module Positioning
  class Triangulation
    include WifiParams

    class << self
      def estimate_by_map(options = {})
        movement_log = options[:movement_log]
        x, y, z = Positioning::WeightedAverage.estimate_by_map(options)
        
      end

      def estimate_by_geom(options = {})
        # target movement_log
        movement_log = options[:movement_log]
        @estimated_geom = []
        # initialize estimated_geom by weighted_average estimation
        @estimated_geom[0] = Positioning::WeightedAverage.estimate_by_geom(options)
        # initialize wifi_access_points related to the movement_log
        @wifi_access_points = WifiAccessPoint.where('movement_log_id = ?', movement_log.id).all(:include => {:wifi_logs => :movement_logs})
        # initialize observation equation
        # seed of the vector rho_i (i = 0..n)
        dist_array = []
        # seed of the matrix [alpha_i, beta_i, gamma_i] (i = 0..n)
        design_array = []
        
        
      end
    end
  end
end
