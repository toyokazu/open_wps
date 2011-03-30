class WifiAccessPoint < ActiveRecord::Base
  has_many :wifi_logs
  belongs_to :manual_location

  class << self
    def find_or_initialize_by_json(json)
      self.find_or_initialize_by_ssid_and_mac(json.reject {|k, v| !self.attribute_method?(k)})
    end

#    def display_histgram(histgram, options = {})
#       Gnuplot.open do |gp|
#         Gnuplot::Plot.new(gp) do |plot|
#           if options[:terminal] =~ /(x11)|(aqua)/
#             plot.terminal options[:terminal]
#           else
#             plot.terminal options[:terminal]
#             plot.output options[:output]
#           end
#           plot.ticslevel 0
#           plot.set("size", "square")
#           plot.data << Gnuplot::DataSet.new([histgram.keys, histgram.keys.map {|i| histgram[i].size}]) do |ds|
#             ds.title = "histgram"
#           end
#         end
#       end
#    end

    def rssi_distance_vectors(options = {})
      wifi_access_points = WifiAccessPoint.where('manual_location_id IS NOT NULL')
      x = nil
      y = nil
      wifi_access_points.each do |ap|
        x_i, y_i = ap.rssi_distance_vectors
        x = x.nil? ? x_i : x.concat(x_i)
        y = y.nil? ? y_i : y.concat(y_i)
      end
      p = x.sort_index
      p.permute(x)
      p.permute(y)
      [x, y]
    end

    def rssi_distance_graph(options = {})
      target = self
      if !options[:wifi_access_point].nil?
        target = options[:wifi_access_point]
      end
      x, y = target.rssi_distance_vectors(options)
      return false if x.nil? || y.nil?
      sigma = GSL::Vector[x.size]
      sigma.set_all(0.1)
      # power fit
      coef, err, chi2, dof = GSL::MultiFit::FdfSolver.fit(-x, y, "power")
      # exp fit
      #coef, err, chi2, dof = GSL::MultiFit::FdfSolver.fit(x, sigma, y, "exponential")
      y0 = coef[0]
      amp = coef[1]
      b = coef[2]
      puts "y0: #{y0}"
      puts "amp: #{amp}"
      puts "b: #{b}"
      # power fit
      puts "#{y0} + #{amp} * GSL::pow(-x_lin, #{b})"
      # exp fit
      #puts "#{y0} + #{amp} * GSL::Sf::exp(#{-b} * x_lin)"
      x_lin = GSL::Vector.linspace(x.min, x.max, 40)
      # power fit
      GSL::graph([x, y], [x_lin, y0+amp*GSL::pow(-x_lin, b)], "-T X -C -S 2 -m 2")
      # exp fit
      #GSL::graph([x, y], [x_lin, y0+amp*GSL::Sf::exp(-b*x_lin)], "-T X -C -S 2 -m 2")
    end
  end

  # Options are:
  # * <tt>:min</tt> - Minimum value of RSSI
  # * <tt>:max</tt> - Maximum value of RSSI
  # * <tt>:n</tt> - Number of bins
  # 
  # Example:
  #   h = WifiAccessPoint.find(10).generate_histogram
  #   # show graph in X11 window
  #   h.graph("-T X -C")
  def rssi_histogram(options = {})
    options = {
      :min => -100,
      :max => -30,
      :n => 7
    }.merge(options)
    min = options[:min]
    max = options[:max]
    interval = options[:n]
    histogram = GSL::Histogram.alloc(interval, [min, max])
    wifi_logs.each do |wifi_log|
      histogram.increment(wifi_log.signal)
    end
    histogram
  end

  # Options are:
  # * <tt>:wifi_logs</tt> - target wifi_logs
  def rssi_distance_vectors(options = {})
    return false if self.manual_location.nil?
    time_condition = ManualLocation.time_condition(options)
    logs = self.wifi_logs.where('movement_logs.manual_location_id IS NOT NULL').where(time_condition).all(:include => {:movement_log => :manual_location})
    x = GSL::Vector.alloc(logs.size)
    y = GSL::Vector.alloc(logs.size)
    logs.each_with_index do |wifi_log, i|
      x[i] = wifi_log.signal.to_f
      y[i] = Positioning::Base.haversine_distance(self.manual_location.geom, wifi_log.movement_log.manual_location.geom)
    end
    p = x.sort_index
    p.permute(x)
    p.permute(y)
    [x, y]
  end

  def rssi_distance_graph(options = {})
    options[:wifi_access_point] = self
    WifiAccessPoint.rssi_distance_graph(options)
  end
end
