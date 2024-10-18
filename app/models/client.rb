class Client < ApplicationRecord
  has_many :historic_consumptions
  has_one :data_summary
  belongs_to :group
  belongs_to :location
  belongs_to :applied_fee_type

  has_many :client_meters
  has_many :meters, through: :client_meters
  has_many :client_notifications
  has_many :notifications, through: :client_notifications

  has_many :client_neighbors
  has_many :neighbors, through: :client_neighbors

  # Returns meter which is currently associated with client (most recently)
  def current_meter
    client_meters.order(created_at: :desc).first.meter
  end

  # Liters consumed between two dates
  def total_consumption_liters(sd, ed)
    sum = 0
    meters.each do |meter|
      sum = sum + meter.total_consumption_liters(sd, ed)
    end
    sum
  end 

  # Consumption from last measruement date up today
  def current_consumption_liters(sd)
    total_consumption_liters(sd, Date.today)
  end 

  def liters_to_clp(cc)
    base_mult = applied_fee_type.base ? 1 : 0
    ap_mult = applied_fee_type.ap ? 1 : 0
    al_mult = applied_fee_type.al ? 1 : 0
    tas_mult = applied_fee_type.tas ? 1 : 0

    clp = location.base_fee*base_mult + location.ap_fee*cc*ap_mult + location.al_fee*cc*al_mult + location.tas_fee*cc*tas_mult
  end

  def current_consumption_clp
    cc = current_consumption_liters(start_date)
    clp = liters_to_clp(cc)
  end

  def current_consumption
    cc = current_consumption_liters(start_date)
    clp = liters_to_clp(cc)
    { liters: cc, clp: clp}
  end

  def projected_consumption
    current_days = (Date.today - start_date).to_i
    total_days = 365.0/12.0 # 30.44: average days in month # Time.days_in_month(Date.today.month,Date.today.year)
    ratio = current_days/total_days
    cc = current_consumption
    { liters: cc[:liters]*ratio, clp: cc[:clp]*ratio }
  end

  #def neighborhood_statistics
  #  means = []
  #  minimums = []

  #  meters.all.each do |meter|
  #    s = meter.neighborhood_statistics(start_date, Date.today)
  #    means.push(s[:mean])
  #    minimums.push(s[:minimum])
  #  end
  #  
  #  { mean: means.reduce(0,:+).to_f/means.size, minimum: minimums.min }
  #end
  
  def neighborhood_statistics
    end_date = Date.today
    consumption_list = []
    neighbors.all.each do |neighbor|
      consumption_list.push(neighbor.total_consumption_liters(start_date, end_date))
    end

    #consumption_list = consumption_list.reject { |num| num < 1 } # discard total consumptions close to zero 
    consumption_list = discard_outliers(consumption_list, 0.05) # discard 0.05% of outliers

    { mean: consumption_list.reduce(0,:+).to_f/consumption_list.size, minimum: consumption_list.min }
  end


  def current_measurement_date
    group.measurement_dates.order(current_date: :desc).first.current_date
  end
  
  def last_measurement_date
    group.measurement_dates.order(last_date: :desc).first.last_date
  end

  # returns start_date for current_consumption calculation
  def start_date
    cd = current_measurement_date
    ld = last_measurement_date
    sd = (Date.today > cd) ? cd : ld
  end

  def current_billing_month
    group.measurement_dates.order(current_date: :desc).first.month
  end

  def history
    hcs = historic_consumptions.order(month: :desc).limit(12)
    current_hc = current_consumption
    current_hc[:month] = get_month_label(current_billing_month)
    current_hc[:year] = current_billing_month.strftime("%Y")
    history_list = [current_hc]

    hcs.each do |hc|
      history_list.push({ month: get_month_label(hc.month), year: hc.month.year.to_s, liters: hc.liters, clp: hc.clp })
    end

    history_list
  end

  def get_month_label(my_date)
    months = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]
    months[my_date.month-1]
  end

  def summary 
    { current_consumption: current_consumption, 
      projected_consumption: projected_consumption,  
      last_measurement_date: last_measurement_date,
      current_measurement_date: current_measurement_date,
      service_number: service_number,
      current_billing_month: current_billing_month }
  end

  def active_client_notifications
    client_notifications.where(status: "active")
  end
 
  def notification_summary
    acns = client_notifications.where(status: "active")
    output = []

    acns.each do |acn|
      output.push({message: acn.notification.message, status: acn.status, created_at: acn.created_at })
    end
    output
  end 
  
  def find_client_notification(start_date, end_date, type_tag)
    ClientNotification.joins(notification: :notification_type).where(client_id: id, created_at: start_date.beginning_of_day..end_date.end_of_day, notification_type: {tag: type_tag}).order(created_at: :asc).first
  end

  def distance_to(candidate)
    lat1 = lat
    lon1 = long
    lat2 = candidate.lat
    lon2 = candidate.long

    earth_radius = 6_371_000 # Radio de la Tierra en metros
    dlat = Client.to_rad(lat2 - lat1)
    dlon = Client.to_rad(lon2 - lon1)

    a = Math.sin(dlat / 2) * Math.sin(dlat / 2) +
      Math.cos(Client.to_rad(lat1)) * Math.cos(Client.to_rad(lat2)) *
        Math.sin(dlon / 2) * Math.sin(dlon / 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    earth_radius * c # Distancia en metros
  end

  def self.to_rad(degrees)
    degrees * Math::PI / 180
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
