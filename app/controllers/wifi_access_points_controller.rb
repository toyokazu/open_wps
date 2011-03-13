class WifiAccessPointsController < ApplicationController
  before_filter :authenticate_user!
  # GET /wifi_access_points/
  # GET /maps/1/wifi_access_points/
  # GET /maps/1/wifi_access_points.xml
  def index
    if !params["map_id"].nil?
      @map = Map.find(params["map_id"])
    end
    if @map.nil?
      @wifi_access_points = WifiAccessPoint.all
    else
      @wifi_access_points = WifiAccessPoint.where('manual_locations.map_id = ?', params["map_id"]).all(:include => [:manual_location])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @wifi_access_points }
    end
  end

  # GET /wifi_access_points/1
  # GET /wifi_access_points/1.xml
  def show
    @wifi_access_point = WifiAccessPoint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @wifi_access_point }
    end
  end

  # GET /wifi_access_points/new
  # GET /wifi_access_points/new.xml
  def new
    @wifi_access_point = WifiAccessPoint.new
    @manual_location = @wifi_access_point.manual_location

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @wifi_access_point }
    end
  end

  # GET /wifi_access_points/1/edit
  def edit
    @wifi_access_point = WifiAccessPoint.find(params[:id])
    @manual_location = @wifi_access_point.manual_location
  end

  # POST /wifi_access_points
  # POST /wifi_access_points.xml
  def create
    @wifi_access_point = WifiAccessPoint.new(params[:wifi_access_point])
    if !params[:manual_location].nil?
      @wifi_access_point.manual_location = ManualLocation.new(params[:manual_location])
    end
    respond_to do |format|
      if @wifi_access_point.save
        format.html { redirect_to(@wifi_access_point, :notice => 'WifiAccessPoint was successfully created.') }
        format.xml  { render :xml => @wifi_access_point, :status => :created, :location => @wifi_access_point }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @wifi_access_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /wifi_access_points/1
  # PUT /wifi_access_points/1.xml
  def update
    @wifi_access_point = WifiAccessPoint.find(params[:id])
    @wifi_access_point.attributes = params[:wifi_access_point]
    if !params[:manual_location].nil?
      if @wifi_access_point.manual_location.nil?
        @wifi_access_point.manual_location = ManualLocation.new(params[:manual_location])
      else
        @manual_location = @wifi_access_point.manual_location
        @manual_location.attributes = params[:manual_location]
        @wifi_access_point.manual_location = @manual_location
      end
    end

    respond_to do |format|
      if @wifi_access_point.save && @manual_location.save
        format.html { redirect_to(@wifi_access_point, :notice => 'WifiAccessPoint was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @wifi_access_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /wifi_access_points/1
  # DELETE /wifi_access_points/1.xml
  def destroy
    @wifi_access_point = WifiAccessPoint.find(params[:id])
    @wifi_access_point.destroy

    respond_to do |format|
      format.html { redirect_to(wifi_access_points_url) }
      format.xml  { head :ok }
    end
  end
end
