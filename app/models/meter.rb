class Meter < ApplicationRecord
  has_many :consumptions
  has_many :client_meters

  has_many :meter_neighbors
  has_many :neighbors, through: :meter_neighbors

  def neighborhood_statistics(start_date, end_date)
    consumption_list = []
    neighbors.all.each do |neighbor|
      consumption_list.push(neighbor.total_consumption_m3(start_date, end_date))
    end

    consumption_list = consumption_list.reject { |num| num < 1 } # discard total consumptions close to zero 
    consumption_list = discard_outliers(consumption_list, 0.1) # discard 10% of outliers

    { mean: consumption_list.reduce(0,:+).to_f/consumption_list.size, minimum: consumption_list.min }
  end

  def total_consumption_m3(start_date, end_date)
    consumptions.where('measured_at > ? AND measured_at <= ?', start_date, end_date).sum(:value)
  end 

  def distance_to(candidate)
    lat1 = lat
    lon1 = long
    lat2 = candidate.lat
    lon2 = candidate.long

    earth_radius = 6_371_000 # Radio de la Tierra en metros
    dlat = Meter.to_rad(lat2 - lat1)
    dlon = Meter.to_rad(lon2 - lon1)

    a = Math.sin(dlat / 2) * Math.sin(dlat / 2) +
      Math.cos(Meter.to_rad(lat1)) * Math.cos(Meter.to_rad(lat2)) *
        Math.sin(dlon / 2) * Math.sin(dlon / 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    earth_radius * c # Distancia en metros
  end

  def self.to_rad(degrees)
    degrees * Math::PI / 180
  end

  def current_client
    client_meters.last.client #TODO: definir la mejor forma de obtener el cliente actual
  end

  def discard_outliers(data, percentage)
    return data if data.empty?
  
    sorted_data = data.sort
    size = sorted_data.size
  
    # Calculate the indices for the bottom and top 10%
    lower_index = (size * percentage).ceil - 1
    upper_index = (size * (1-percentage)).floor
  
    # Create a new array excluding the bottom 10% and top 10%
    filtered_data = sorted_data[(lower_index + 1)..upper_index]
  
    filtered_data
  end

end
