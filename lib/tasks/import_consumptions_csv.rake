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

  task :import_alertas, [:fn] => :environment do |t, args|
    desc "Import alerts from Alcia CSV file"
    csv_text = File.read(args[:fn])

    Alerta.delete_all

    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      Alerta.create!(row.to_hash)
    end
  end

  task :translate_from_alcia => :environment do |t, args|
    desc "Copy data from bridge tables to main tables"
  
    ConsumoPorHora.all.each do |c|
      mid = Meter.find_by(deveui: c.deveui)
      if mid.nil?
        puts "Meter #{c.deveui} doesn't exist"
      else
        dt = DateTime.new(c.fecha.year, c.fecha.month, c.fecha.day, c.hora.hour, c.hora.min, c.hora.sec)
        Consumption.create!(value: c.consumo, accumulated_value: c.consumo_acumulado, meter_id: mid.id, measured_at: dt)
      end
    end
  end

  task :calculate_metrics, [:month] => :environment do |t, args|
    desc "Copy consumptions from bridge table (consumptions_per_hour) to main table"
    
    month = Date.parse(args[:month]).change(day: 1) # month periods for historic consumption

    Meter.all.each do |m|
      start_date = m.group.measurement_dates.find_by(month: month).last_date
      end_date = m.group.measurement_dates.find_by(month: month).current_date
      total_value = m.consumptions.where('created_at >= ? AND created_at <= ?', start_date, end_date).sum(:value)
      hc = HistoricConsumption.where(meter: m, month: month).first_or_create
      hc.update(value: total_value, month: month, meter: m)
     
      tarifa = 100 # TODO: tarifa should be calculated in some way
      cc = m.consumptions.where('created_at >= ? AND created_at <= ?', end_date, Date.today).sum(:value)
      ccclp = cc*tarifa
      cpclp = HistoricConsumption.where(meter: m, month: month.change(year: month.year-1))*tarifa

      if m.data_summary.nil?
        m.data_summary.create(current_consumption: cc, current_consumption_clp: ccclp, projected_consumption_clp: pcclp, meter: m)
      else
        m.data_summary.update(current_consumption: cc, current_consumption_clp: ccclp, projected_consumption_clp: pcclp, meter: m)
      end
    end
  end

end
