require 'csv'    
require 'rake'

namespace :bridge do
  desc "Tasks for manipulating bridge data inserted by Alcia"

  task :import_consumptions, [:fn] => :environment do |t, args|
    desc "Import consumptions from Alcia CSV file"
    csv_text = File.read(args[:fn])

    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      ConsumptionPerHour.create!(row.to_hash)
    end
  end

  task :translate_consumptions => :environment do |t, args|
    desc "Copy consumptions in bridge table to main table"
    
    ConsumptionPerHour.all.each do |c|
      mid = Meter.find_by(deveui: c.deveui)
      if mid.nil?
        mid = Meter.create!(deveui: c.deveui)
      end
      dt = DateTime.new(c.fecha.year, c.fecha.month, c.fecha.day, c.hora.hour, c.hora.min, c.hora.sec)
      Consumption.create!(value: c.consumo, accumulated_value: c.consumo_acumulado, meter_id: mid.id, measured_at: dt)
    end
  end
end
