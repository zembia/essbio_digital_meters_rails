class Client < ApplicationRecord
  has_many :historic_consumptions
  has_one :data_summary
  belongs_to :group
  belongs_to :location
  belongs_to :applied_fee_type

  has_many :client_meters
  has_many :meters, through: :client_meters

  # Returns meter which is currently associated with client (most recently)
  def current_meter
    meters.last
  end

  # Consumption from last measruement date until today
  def current_consumption_m3
    sum = 0
    meters.each do |meter|
      sum = sum + meter.current_consumption_m3(start_date, Date.today)
    end
    sum
  end 

  def m3_to_clp(cc)
    base_mult = applied_fee_type.base ? 1 : 0
    ap_mult = applied_fee_type.ap ? 1 : 0
    al_mult = applied_fee_type.al ? 1 : 0
    tas_mult = applied_fee_type.tas ? 1 : 0

    clp = location.base_fee*base_mult + location.ap_fee*cc*ap_mult + location.al_fee*cc*al_mult + location.tas_fee*cc*tas_mult
  end

  def current_consumption_clp
    cc = current_consumption_m3(start_date)
    clp = m3_to_clp(cc)
  end

  def current_consumption
    cc = current_consumption_m3(start_date)
    clp = m3_to_clp(cc)
    { m3: cc, clp: clp}
  end

  def projected_consumption
    total_days = (Date.today - Client.second.last_measurement_date).to_i.abs
    diary_consumption = current_consumption/total_days
    diary_consumption*Time.days_in_month(Date.today.month,Date.today.year)
  end

  def neighborhood_statistics
    means = []
    minimums = []

    meters.all.each do |meter|
      s = meter.neighborhood_statistics(start_date, Date.today)
      means.push(s[:mean])
      minimums.push(s[:minimum])
    end
    
    { mean: means.reduce(0,:+).to_f/means.size, minimum: minimums.min }
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

end
