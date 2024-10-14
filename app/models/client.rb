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

  # Returns meter which is currently associated with client (most recently)
  def current_meter
    client_meters.order(created_at: :desc).first.meter
  end

  # Consumption from last measruement date until today
  def current_consumption_m3(sd)
    sum = 0
    meters.each do |meter|
      sum = sum + meter.total_consumption_m3(sd, Date.today)
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
    current_days = (Date.today - Client.second.last_measurement_date).to_i.abs
    total_days = Time.days_in_month(Date.today.month,Date.today.year)
    ratio = current_days/total_days
    cc = current_consumption
    { m3: cc[:m3]*ratio, clp: cc[:clp]*ratio }
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

  def history
    hcs = historic_consumptions.order(month: :desc).limit(12)
    current_hc = current_consumption
    current_hc[:month] = get_month_label(current_billing_month)
    current_hc[:year] = current_billing_month.strftime("%Y")
    history_list = [current_hc]

    hcs.each do |hc|
      history_list.push({ month: get_month_label(hc.month), year: hc.month.year.to_s, m3: hc.m3, clp: hc.clp })
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
end
