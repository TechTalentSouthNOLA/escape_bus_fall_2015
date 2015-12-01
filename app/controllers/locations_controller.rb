class LocationsController < ApplicationController
  include LocationsHelper # module with our helper methods
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  # GET /locations
  # GET /locations.json
  def index
    @locations = Location.all
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    # MARTA API URL
    source = 'http://developer.itsmarta.com/BRDRestService/RestBusRealTimeService/GetAllBus'

    # Use our helper method to parse the data from the API
    @buses = fetch_api_data(source)

    # Loop through all buses and return only those that are nearby
    @nearby_buses = []

    @buses.each do |bus|
      user_lat = @location.latitude
      user_long = @location.longitude
      bus_lat = bus['LATITUDE'].to_f
      bus_long = bus['LONGITUDE'].to_f

      if is_nearby?(user_lat, user_long, bus_lat, bus_long, @location.distance)
        @nearby_buses << bus
      end
    end

    if @nearby_buses.empty?
      redirect_to edit_location_url(@location), notice: "No locations nearby.  Try editing your location."
    end
  end

  # GET /locations/new
  def new
    @location = Location.new
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, notice: 'Location was successfully created.' }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: 'Location was successfully updated.' }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url, notice: 'Location was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.require(:location).permit(:address, :city, :latitude, :longitude, :distance)
    end
end
