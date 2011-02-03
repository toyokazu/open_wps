class WifiLogsController < ApplicationController
  before_filter :authenticate_user!

  # GET /wifi_logs/new
  # GET /wifi_logs/new.xml
  # GET /maps/1/wifi_logs/new
  # GET /maps/1/wifi_logs/new.xml
  def new
    @wifi_log = WifiLog.new
    if !params[:map_id].nil?
      @map = Map.find(params[:map_id])
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @wifi_log }
    end
  end

  # POST /maps/1/wifi_logs
  # POST /maps/1/wifi_logs
  def create
    WifiLog.transaction do
      @manual_location = ManualLocation.new
      @manual_location.init_by_params(params)
      @manual_location.save!

      @gpsd_tpv = nil
      @gps_location = nil
      if !params["gpsd_tpv"].nil?
        @gpsd_tpv = JSON.parse(params["gpsd_tpv"])
        if !@gpsd_tpv.empty?
          @gps_location = GpsLocation.new_by_json(@gpsd_tpv)
          @gps_location.save!
        end
      end
      @movement_log = MovementLog.new
      @movement_log.manual_location = @manual_location
      @movement_log.gps_location = @gps_location
      # FIXME
      # how to specify current user in Devise
      @movement_log.user = current_user
      @movement_log.remote_addr = request.remote_addr
      @movement_log.user_agent = request.user_agent
      @movement_log.user_device = params["user_device"]

      @wifi_towers = JSON.parse(params["wifi_towers"])
      @wifi_towers.each do |wifi_tower|
        @wifi_access_point = WifiAccessPoint.find_or_initialize_by_json(wifi_tower)
        if !@wifi_access_point.persisted?
          @wifi_access_point.save!
        end
        @wifi_log = WifiLog.new_by_json(wifi_tower)
        @wifi_log.wifi_access_point = @wifi_access_point
        @wifi_log.movement_log = @movement_log
        @wifi_log.save!
      end
    end

    # FIXME
    # how to detect transaction rollback in transaction method
    # set flag in transaction method then process as follows
    # this method is called by JavaScript XMLHttpRequest
    # so thus json reply may be adequate
    respond_to do |format|
      if @map.save
        format.html { redirect_to(@map, :notice => 'Map was successfully created.') }
        format.xml  { render :xml => @map, :status => :created, :location => @map }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @map.errors, :status => :unprocessable_entity }
      end
    end
  end

end
