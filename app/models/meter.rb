class Meter < ApplicationRecord
  has_many :consumptions
  has_many :client_meters


  def total_consumption_liters(start_date, end_date)
    consumptions.where('measured_at > ? AND measured_at <= ?', start_date, end_date).sum(:value)
  end 

  def current_client
    #TODO: definir la mejor forma de obtener el cliente actual
    cm = client_meters.last
    cm.nil? ? nil : cm.client 
  end

end
