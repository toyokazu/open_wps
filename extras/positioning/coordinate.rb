# -*- coding: utf-8 -*-
module Positioning
  module Coordinate
    SRID = 4612 # JGD2000
    #SRID = 4326 # WGS84
    # radius of the earth (m)
    R = 6370997.0

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def deg_to_rad(deg)
        deg * Math::PI / 180
      end

      def rad_to_deg(rad)
        rad * 180 / Math::PI
      end

      def geom_to_rad(geom)
        [0, 0, 0, 0] if geom.nil?
        [self.deg_to_rad(geom.lon), self.deg_to_rad(geom.lat), geom.z, geom.srid]
      end

      def rad_to_geom(lon, lat, z, srid)
        Point.from_lon_lat_z(self.rad_to_deg(lon), self.rad_to_deg(lat), z, srid)
      end

      def haversine_distance2d_by_sql(geom1, geom2)
        calculate(:haversine_distance2d, sanitize_sql(['?, ?', geom1, geom2]), :limit => 1).to_f
      end

      def haversine_distance2d(geom1, geom2)
        lon1, lat1, z1, srid1 = self.geom_to_rad(geom1)
        lon2, lat2, z2, srid2 = self.geom_to_rad(geom2)
        r = R
        dlon = lon2 - lon1
        dlat = lat2 - lat1
        a = Math.sin(dlat / 2) * Math.sin(dlat / 2) + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dlon / 2) * Math.sin(dlon / 2)
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
        d = r * c
      end

      def haversine_distance_x(geom1, geom2)
        geom3 = geom2.clone
        geom3.y = geom1.y
        geom3.z = geom1.z
        haversine_distance2d(geom1, geom3)
      end

      def haversine_distance_y(geom1, geom2)
        geom3 = geom2.clone
        geom3.x = geom1.x
        geom3.z = geom1.z
        haversine_distance2d(geom1, geom3)
      end

      def haversine_distance(geom1, geom2)
        d_2d = haversine_distance2d(geom1, geom2)
        d_3d = Math.sqrt(d_2d ** 2 + (geom2.z - geom1.z) ** 2)
      end

      # 引数 ---
      # start: 始点の Point (緯度，経度, 高さ, OpenGIS の座標系)
      # brng: 始点から終点の方位角 (北方向から時計回りの角度)
      # d: 始点から終点までの球面距離 (m)
      # r: 球面の半径 (6378137) (m)
      #
      # 戻り値 ---
      # 終点の Point (緯度，経度, 高さ, OpenGIS の座標系)
      def point_in_dist(options = {})
        lon1, lat1, z, srid = self.geom_to_rad(options[:start])
        if !options[:rad_brng].nil?
          brng = options[:rad_brng]
        else
          brng = self.deg_to_rad(options[:brng] || 0)
        end
        d = options[:d].to_f || 0
        r = options[:r] || R
        #r = options[:r] || 6378137
        lat2 = Math.asin( Math.sin(lat1) * Math.cos(d/r) +
                          Math.cos(lat1) * Math.sin(d/r) * Math.cos(brng) )
        lon2 = lon1 + Math.atan2( Math.sin(brng) * Math.sin(d/r) * Math.cos(lat1),
                                  Math.cos(d/r) - Math.sin(lat1) * Math.sin(lat2) )
        self.rad_to_geom(lon2, lat2, z, srid)
      end
    end
  end
end
