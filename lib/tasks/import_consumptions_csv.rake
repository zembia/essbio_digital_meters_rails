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
    desc "Assign random latlongs to clients"

    Client.all.each do |client|
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

      client.update(lat: new_lat, long: new_lon)
    end
  end

  task :translate_from_alcia, [:maestrocliente,:consumo_por_hora,:alertas] => :environment do |t, args|
    desc "Copy data from bridge tables to main tables"
 
    if args[:maestrocliente] == "true"
      puts "Translating data from maestrocliente"

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
    end

    if args[:consumo_por_hora] == "true"
      puts "Translating data from consumo_por_hora"

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

    if args[:alertas] == "true"
      puts "Translating data from alertas"
      # IMPORTANT: remenber that Alert model != Alerta model
      Alerta.all.each do |a| # read all alertas from bridge table
        next if !("Leakage".in?(a.statemessages)) # TODO: in the future it would be necessary to process other alert types
        
        meter = Meter.find_by(deveui: a.deveui)
        next if meter.nil?

        at = AlertType.find_by(name: "Leakage") 
        alert = Alert.where(meter: meter, alert_type: at, logdate: a.logdate, lectura1: a.lectura1).first_or_create
      end
    end
  end

  task :calculate_neighbors, [:radius] => :environment do |t, args|
    desc "Calculate neighbors" # TODO: define frequency at which this should be executed
    ClientNeighbor.delete_all

    Client.all.each do |client|
      Client.all.each do |candidate|
        if client.distance_to(candidate) < args[:radius].to_f
          ClientNeighbor.create(client: client, neighbor: candidate) unless (client.id == candidate.id)
        end
      end
    end
  end

  task :calculate_metrics, [:month] => :environment do |t, args|
    desc "Calculate historic consumptions" # this should be executed once per day
    
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

  task :process_alerts, [:a_date] => :environment do |t, args|
    desc "Process Alerts and create Notifications" # this should be executed once per day
   
    a_date = args[:a_date].nil? ? Date.today : Date.parse(args[:a_date])
    max_level = 2

    Meter.all.each do |meter|
      AlertType.all.each do |at|
        next if at.tag != "leakage" # TODO: remove this line if we want to analyze other types of alerts
        
        # skip iteration if meter has no client asociated
        next if meter.current_client.nil?

        # skip iteration if notification was already created today for this meter and type
        next if meter.current_client.find_client_notification(a_date.beginning_of_day, a_date.end_of_day, at.tag) 
        
        # get the first alert that appeared on that day, of the type and meter specified
        a = Alert.where(meter: meter, alert_type: at, logdate: a_date.beginning_of_day..a_date.end_of_day).order(logdate: :asc).last # most recent
        next if a.nil? # skip iteration if no alerts are present

        a_yesterday = Alert.where(meter: meter, alert_type: at, logdate: (a_date-1).beginning_of_day..(a_date-1).end_of_day).order(logdate: :asc).first
        a_before_yesterday = Alert.where(meter: meter, alert_type: at, logdate: (a_date-2).beginning_of_day..(a_date-2).end_of_day).order(logdate: :asc).first
        next if (a_yesterday.nil? || a_before_yesterday.nil?) # skip iteration if criteria isn't met
        
        ## Search for already created notifications with the same type "leakage"
        prev_cn = meter.current_client.find_client_notification((a_date-1.days).beginning_of_day, (a_date-1.days).end_of_day, at.tag)
        # if there aren't, level for this ClientNotification is 1 -> message: "Hay una fuga..."
        # but if there are any "leakage" ones, level should be 2 -> message: "Sigue habiendo una fuga..."
        level = prev_cn.nil? ? 1 : ((prev_cn.level < max_level) ? prev_cn.level + 1 : max_level)
        
        puts "Creating notification! #{meter.meter_number} #{a.logdate} #{a_yesterday.logdate} #{a_before_yesterday.logdate} level: #{level}"
        cn = ClientNotification.create(notification: Notification.find_by(notification_type: NotificationType.find_by(tag: at.tag), level: level), meter: meter, client: meter.current_client, status: "active")
        NotificationAlert.create(client_notification: cn, alert: a)
        NotificationAlert.create(client_notification: cn, alert: a_before_yesterday)
      end
    end
  end

  task :update_consumption_date => :environment do |t, args|
    Consumption.all.each do |c|
      c.update(measured_at: c.measured_at + 1.months)
    end
  end
end
