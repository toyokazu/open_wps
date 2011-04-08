module Positioning
  module WifiProperty
    MAX_RSSI = -50
    MIN_RSSI = -95
    RSSI_RANGE = (MAX_RSSI - MIN_RSSI).abs
    ### constants defined in rekimoto-san's paper
    C0 = 0.6469894761514456
    C1 = -0.006121707332415853
    A = (95 * Math::log10(140) - 90 * Math::log10(220)) / (Math.log10(220) - Math::log10(140))
    B = 5 / (Math::log10(220) - Math::log10(140))
    A_MAX = (95 * Math::log10(240) - 90 * Math::log10(320)) / (Math::log10(320) - Math::log10(240))
    B_MAX = 5 / (Math::log10(320) - Math::log10(240))
    ### additionally define A_MIN, B_MIN value
    A_MIN = (95 * Math::log10(10) - 90 * Math::log10(50)) / (Math::log10(50) - Math::log10(10))
    B_MIN = 5 / (Math::log10(50) - Math::log10(10))

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def rssi_from_dist(dist)
        A - B * Math::log10(dist)
      end

      def dist
        "pow(10, (#{A} - wifi_logs.signal) / #{B})"
      end

      def dist_value(rssi)
        10 ** (C0 + C1 * rssi)
        # 10 ** ((A - rssi) / B)
      end

      def dist_max
        "pow(10, (#{A_MAX} - wifi_logs.signal) / #{B_MAX})"
      end

      def dist_max_value(rssi)
        10 ** ((A_MAX - rssi) / B_MAX)
      end

      def dist_min
        "pow(10, (#{A_MIN} - wifi_logs.signal) / #{B_MIN})"
      end

      def dist_min_value(rssi)
        10 ** ((A_MIN - rssi) / B_MIN)
      end
    end
  end
end
