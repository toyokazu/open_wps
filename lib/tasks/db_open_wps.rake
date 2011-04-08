namespace :db do
  REJECT_ATTRS = ["id", "created_at", "updated_at"]
  def check_existings_condition(instance, extra_attrs = [])
    instance.attributes.reject {|k,v| REJECT_ATTRS.concat(extra_attrs).include?(k) || k =~ /_id/}
  end

  def id_cond(src, type)
    src.send("#{type}_id").nil? ? {} : {"#{type}_id".to_sym => eval("@#{type}_rels[src.send(\"\#{type}_id\")]")}
  end

  def id_conv(src, type)
    src.send("#{type}_id").nil? ? nil : eval("@#{type}_rels[src.send(\"\#{type}_id\")]")
  end

  desc 'Copy data from WpsLogger DB (:wps_logger in database.yml) to OpenWps DB (:development or :production). WpsLogger Rails.root is assumed to be "#{Rails.root}/../wps_logger".'
  task :copy => :environment do
    begin
      after = ENV["AFTER"].nil? ? Time.new(1970,01,01) : Time.zone.parse(ENV["AFTER"])
      before = ENV["BEFORE"].nil? ? Time.new(2031,01,01) : Time.zone.parse(ENV["BEFORE"])
      between = {:updated_at => after..before}

      @user_rels = []
      @users = WpsLogger::User.all
      @users.each do |src_user|
        dst_user = User.where(:email => src_user.email).first
        if dst_user.nil?
          dst_user = User.new(src_user.attributes)
          dst_user.encrypted_password = src_user.encrypted_password
          dst_user.password_salt = src_user.password_salt
          dst_user.sign_in_count = src_user.sign_in_count
          dst_user.save
        end
        @user_rels[src_user.id] = dst_user.id
      end

      @map_rels = []
      @maps = WpsLogger::Map.all
      @maps.each do |src_map|
        dst_map = Map.where(:name => src_map.name).first
        if dst_map.nil?
          dst_map = Map.new(src_map.attributes)
          dst_map.save
          FileUtils.cp_r("#{Rails.root}/../wps_logger/public/system/images/#{src_map.id}/",
                        "#{Rails.root}/public/system/images/#{dst_map.id}/")
        end
        @map_rels[src_map.id] = dst_map.id
      end

      @map_relation = WpsLogger::MapRelation.where(between).all
      @map_relation.each do |src_map_relation|
        dst_map_relation = MapRelation.where(check_existings_condition(src_map_relation))
        if dst_map_relation.nil? || dst_map_relation.empty?
          dst_map_relation = MapRelation.new(src_map_relation.attributes)
          dst_map_relation.basis_map_id = @map_rels[src_map_relation.basis_map_id]
          dst_map_relation.relative_map_id = @map_rels[src_map_relation.relative_map_id]
          dst_map_relation.save
        end
      end
      
      @gps_location_rels = []
      @gps_locations = WpsLogger::GpsLocation.all
      @gps_locations.each do |src_gps_location|
        dst_gps_location = GpsLocation.where(check_existings_condition(src_gps_location)).first
        if dst_gps_location.nil?
          dst_gps_location = GpsLocation.new(src_gps_location.attributes)
          dst_gps_location.save
        end
        @gps_location_rels[src_gps_location.id] = dst_gps_location.id
      end
      
      # copy wifi_access_points
      # copy manual_locations where :time => nil
      # those manual_locations are recorded for wifi_access_point
      @wifi_access_point_rels = []
      @manual_location_rels = []
      @wifi_access_points = WpsLogger::WifiAccessPoint.all
      @wifi_access_points.each do |src_wap|
        dst_wap = WifiAccessPoint.where(:mac => src_wap.mac).first
        if dst_wap.nil?
          dst_wap = WifiAccessPoint.new(src_wap.attributes)
          if (src_manual_location = src_wap.manual_location)
            dst_manual_location = ManualLocation.new(src_manual_location.attributes)
            dst_manual_location.map_id = id_conv(src_manual_location, "map")
            dst_manual_location.save
            @manual_location_rels[src_manual_location.id] = dst_manual_location.id
          end
          dst_wap.manual_location_id = id_conv(src_wap, "manual_location")
          dst_wap.save
        else
          if (src_manual_location = src_wap.manual_location)
            dst_manual_location = dst_wap.manual_location
            dst_manual_location.attributes = src_manual_location.attributes
            dst_manual_location.map_id = id_conv(src_manual_location, "map")
            dst_manual_location.save
            @manual_location_rels[src_manual_location.id] = dst_wap.manual_location.id
          end
        end
        @wifi_access_point_rels[src_wap.id] = dst_wap.id
      end

      @manual_location_rels = []
      # @manual_locations = WpsLogger::ManualLocation.where('time IS NOT NULL').all
      @manual_locations = WpsLogger::ManualLocation.where('wifi_access_points.manual_location_id IS NULL').all(:include => :wifi_access_point)
      @manual_locations.each do |src_manual_location|
        dst_manual_location = ManualLocation.where(check_existings_condition(src_manual_location).merge(id_cond(src_manual_location, "map"))).first
        if dst_manual_location.nil?
          dst_manual_location = ManualLocation.new(src_manual_location.attributes)
          dst_manual_location.map_id = id_conv(src_manual_location, "map")
          dst_manual_location.save
          @manual_location_rels[src_manual_location.id] = dst_manual_location.id
        end
      end

      @movement_log_rels = []
      @movement_logs = WpsLogger::MovementLog.all
      @movement_logs.each do |src_movement_log|
        dst_movement_log = MovementLog.where(id_cond(src_movement_log, "gps_location").
                                             merge(id_cond(src_movement_log, "manual_location")).
                                             merge(id_cond(src_movement_log, "user")).
                                             merge({:remote_addr => src_movement_log.remote_addr,
                                                     :user_device => src_movement_log.user_device})).first
        if dst_movement_log.nil?
          dst_movement_log = MovementLog.new(src_movement_log.attributes)
          dst_movement_log.gps_location_id = id_conv(src_movement_log, "gps_location")
          dst_movement_log.manual_location_id = id_conv(src_movement_log, "manual_location")
          dst_movement_log.user_id = id_conv(src_movement_log, "user")
          dst_movement_log.save
        end
        @movement_log_rels[src_movement_log.id] = dst_movement_log.id
      end

      # @wifi_log_rels = []
      @wifi_logs = WpsLogger::WifiLog.where(between).all
      @wifi_logs.each do |src_wifi_log|
        dst_wifi_log = WifiLog.where(id_cond(src_wifi_log, "wifi_access_point").
                                     merge(id_cond(src_wifi_log, "movement_log")).
                                     merge({:signal => src_wifi_log.signal})).first
        if dst_wifi_log.nil?
          dst_wifi_log = WifiLog.new(src_wifi_log.attributes)
          dst_wifi_log.wifi_access_point_id = id_conv(src_wifi_log, "wifi_access_point")
          dst_wifi_log.movement_log_id = id_conv(src_wifi_log, "movement_log")
          dst_wifi_log.save
        end
        # @wifi_log_rels[src_wifi_log.id] = dst_wifi_log.id
      end
    rescue => error
      puts "#{error.class} - #{error.message}"
      puts "Error during db:copy"
    end
  end

  namespace :generate do
    task :geom => :environment do
      #FIXME
      @maps = Map.all
      @maps.each do |map|
        map.geom = Point.from_lon_lat_z(map.o_lon, map.o_lat, map.o_alt, Positioning::Coordinate::SRID)
        map.save
      end

      @gps_locations = GpsLocation.all
      @gps_locations.each do |gps_location|
        gps_location.geom = Point.from_lon_lat_z(gps_location.lon, gps_location.lat, gps_location.alt, SRID)
        gps_location.save
      end

      @manual_locations = ManualLocation.all
      @manual_locations.each do |manual_location|
        vec = GSL::Vector.alloc([manual_location.x - manual_location.map.o_x, manual_location.y - manual_location.map.o_y])
        vec_brng = Math::PI / 2 - Math::atan2(vec[1], vec[0]) + manual_location.map.brng
        vec_len = Math::sqrt(vec.inner_product(vec)) * manual_location.map.dist_pix_ratio
        geom = Positioning::Base.point_in_dist(:start => manual_location.map.geom, :brng => vec_brng, :d => vec_len)
        geom.z = manual_location.map.geom.z + manual_location.height
        manual_location.geom = geom
        manual_location.save
      end
    end
  end
end
