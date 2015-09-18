class StationsController < ApplicationController
  before_filter :set_access
  def index
    @stations = Station.all
    render json: @stations
  end

  def show
    @station = Station.find(params[:id])
    @station_status = Station.fetch(@station.cabi_id)
    delta = @station.delta(@station.id, @station_status[:nbBikes].to_i, @station_status[:nbEmptyDocks].to_i)
    render json: {
        data: @station,
        nbBikes: @station_status[:nbBikes].to_i,
        nbEmptyDocks: @station_status[:nbEmptyDocks].to_i,
        delta: delta
      }
  end

  def status
    @stations = Station.status
    render json: @stations.to_json
  end

  def set_access
    headers['Access-Control-Allow-Origin'] = '*'
  end
end
