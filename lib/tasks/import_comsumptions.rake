desc "Import consumptions from Alcia CSV file"
require 'csv'    
require 'rake'

task :import_consumptions, [:fn] do |t, args|
  puts args
  csv_text = File.read(args[:fn])
  csv = CSV.parse(csv_text, :headers => true)
  csv.each do |row|
    puts row.to_hash
    debugger
    ConsumptionPerHour.create!(row.to_hash)
  end
end
