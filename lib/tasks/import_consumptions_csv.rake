require 'csv'    
require 'rake'

namespace :bridge do
  desc "Tasks for manipulating bridge data inserted by Alcia"

  task :import_consumos_por_hora, [:fn] => :environment do |t, args|
    desc "Import consumptions from Alcia CSV file"
    csv_text = File.read(args[:fn])
    
    ConsumoPorHora.delete_all

    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      ConsumoPorHora.create!(row.to_hash)
    end
  end

  task :import_maestroclientes, [:fn] => :environment do |t, args|
    desc "Import maestroclientes from Alcia CSV file"
    csv_text = File.read(args[:fn])
    
    Maestrocliente.delete_all

    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      Maestrocliente.create!(row.to_hash)
    end
  end

  task :import_alertas, [:fn] => :environment do |t, args|
    desc "Import alerts from Alcia CSV file"
    csv_text = File.read(args[:fn])

    Alerta.delete_all

    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      Alerta.create!(row.to_hash)
    end
  end

  task :assign_random_latlongs, [:center_lat, :center_lon, :radius] => :environment do |t, args|
    desc "Assign random latlongs to meters"

    Meter.all.each do |meter|
      angle = rand(0..360)
      center_lat = args[:center_lat].to_f
      center_lon = args[:center_lon].to_f

      # Calcular la distancia en radianes
      distance_in_radians = args[:radius].to_f / 6371000.0 # Radio de la Tierra en metros

      # Calcular la nueva latitud
      new_lat = Math.asin(Math.sin(center_lat * Math::PI / 180) * Math.cos(distance_in_radians) +
                          Math.cos(center_lat * Math::PI / 180) * Math.sin(distance_in_radians) * Math.cos(angle * Math::PI / 180)) * 180 / Math::PI

      # Calcular la nueva longitud
      new_lon = (center_lon * Math::PI / 180) + Math.atan2(Math.sin(angle * Math::PI / 180) * Math.sin(distance_in_radians) * Math.cos(center_lat * Math::PI / 180),
                                                             Math.cos(distance_in_radians) - Math.sin(center_lat * Math::PI / 180) * Math.sin(new_lat * Math::PI / 180))

      # Convertir de radianes a grados
      new_lon = new_lon * 180 / Math::PI

      meter.update(lat: new_lat, long: new_lon)
    end
  end

  task :translate_from_alcia => :environment do |t, args|
    desc "Copy data from bridge tables to main tables"
 
    Maestrocliente.all.each do |m|
      meter = Meter.find_by(meter_number: m.numero_medidor)

      if meter.nil?
        puts "Meter #{m.numero_medidor} doesn't exist. Creating it"
        meter = Meter.create(deveui: m.deveui, meter_number: m.numero_medidor)
      end
      
      client = Client.find_by(service_number: m.id_servicio)
      if client.nil?
        puts "Client #{m.id_servicio} doesn't exist. Cannot create association."
        next
      end
     
      puts "Creating association between meter #{meter.meter_number} and client #{client.service_number}"
      ClientMeter.where(meter: meter, client: client).first_or_create

      # Maestrocliente.delete
    end

    ConsumoPorHora.all.each do |c|
      meter = Meter.find_by(deveui: c.deveui)
      if meter.nil?
        puts "Meter #{c.deveui} doesn't exist"
      else
        dt = DateTime.new(c.fecha.year, c.fecha.month, c.fecha.day, c.hora.hour, c.hora.min, c.hora.sec)
        Consumption.create!(value: c.consumo, accumulated_value: c.consumo_acumulado, meter: meter, measured_at: dt)
      end
    end
  end

  task :calculate_neighbors, [:radius] => :environment do |t, args|
    desc "Calculate neighbors"
    MeterNeighbor.delete_all

    Meter.all.each do |meter|
      Meter.all.each do |candidate|
        if meter.distance_to(candidate) < args[:radius].to_f
          MeterNeighbor.create(meter: meter, neighbor: candidate) unless (meter.id == candidate.id)
        end
      end
    end
  end

  task :calculate_metrics, [:month] => :environment do |t, args|
    desc "Copy consumptions from bridge table (consumptions_per_hour) to main table"
    
    month = Date.parse(args[:month]).change(day: 1) # month periods for historic consumption

    Client.all.each do |client|
      if Date.today == client.current_measurement_date
        total_value = client.current_consumption_m3
        billing_month = client.current_billing_month
        hc = HistoricConsumption.where(client: client, month: billing_month).first_or_create
        hc.update(value: total_value, month: billing_month, client: client)
      end
    end
  end
end
