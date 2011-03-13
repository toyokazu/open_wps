class MapsController < ApplicationController
  before_filter :authenticate_user!
  # GET /maps
  # GET /maps/1/maps
  # GET /maps.xml
  def index
    if !params["map_id"].nil?
      @map = Map.find(params["map_id"])
    end
    @maps = Map.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maps }
    end
  end

  # GET /maps/1
  # GET /maps/1/maps/2
  # GET /maps/1.xml
  def show
    @map = Map.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @map }
    end
  end

  # GET /maps/new
  # GET /maps/new.xml
  def new
    @map = Map.new
    @maps = Map.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @map }
    end
  end

  # GET /maps/1/edit
  def edit
    @map = Map.find(params[:id])
    @maps = Map.all
  end

  # POST /maps
  # POST /maps.xml
  def create
    if !params[:basis_map_relation].nil? && params[:basis_map_relation][:id] != '-1'
      @basis_map = Map.find(params[:basis_map_relation][:id])
    end
    @map = Map.new(params[:map])
    if !params[:use_gpsd_tpv].nil?
      gpsd_tpv = JSON.parse(params[:gpsd_tpv])
      @map.o_lat = gpsd_tpv["lat"]
      @map.o_lon = gpsd_tpv["lon"]
      @map.o_alt = gpsd_tpv["alt"]
    end
    if @basis_map.nil?
      if !@map.basis_map_relation.nil?
        @map.basis_map_relation.delete
      end
    else
      @map.basis_map = @basis_map
      @map.basis_map_relation.alt_diff = params[:basis_map_relation][:alt_diff]
      @map.basis_map_relation.brng_diff = params[:basis_map_relation][:brng_diff]
      @map.basis_map_relation.ref_x = params[:basis_map_relation][:ref_x]
      @map.basis_map_relation.ref_y = params[:basis_map_relation][:ref_y]
    end

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

  # PUT /maps/1
  # PUT /maps/1.xml
  def update
    @map = Map.find(params[:id])
    # update instance
    @map.attributes = params[:map]
    if !params[:use_gpsd_tpv].nil?
      gpsd_tpv = JSON.parse(params[:gpsd_tpv])
      @map.o_lat = gpsd_tpv["lat"]
      @map.o_lon = gpsd_tpv["lon"]
      @map.o_alt = gpsd_tpv["alt"]
    end
    if !params[:basis_map_relation].nil? && params[:basis_map_relation][:id] != '-1'
      @basis_map = Map.find(params[:basis_map_relation][:id])
    end
    if @basis_map.nil?
      if !@map.basis_map_relation.nil?
        @map.basis_map_relation.delete
      end
    else
      @map.basis_map = @basis_map
      @map.basis_map_relation.alt_diff = params[:basis_map_relation][:alt_diff]
      @map.basis_map_relation.brng_diff = params[:basis_map_relation][:brng_diff]
      @map.basis_map_relation.ref_x = params[:basis_map_relation][:ref_x]
      @map.basis_map_relation.ref_y = params[:basis_map_relation][:ref_y]
    end

    respond_to do |format|
      if @map.save && (@map.basis_map_relation.nil? ||
                       (!@map.basis_map_relation.nil? &&
                        @map.basis_map_relation.save))
        format.html { redirect_to(@map, :notice => 'Map was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /maps/1
  # DELETE /maps/1.xml
  def destroy
    @map = Map.find(params[:id])
    @map.destroy

    respond_to do |format|
      format.html { redirect_to(maps_url) }
      format.xml  { head :ok }
    end
  end
end
