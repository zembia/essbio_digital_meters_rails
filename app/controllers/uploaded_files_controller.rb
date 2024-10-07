class UploadedFilesController < ApplicationController
  def index
    @file_types = FileType.all
  end

  def upload_files
    uploaded_file = UploadedFile.new(file_type_id: params[:file_type_id])

    # Adjuntar archivos a cada instancia
    uploaded_file.file.attach(params[:file1]) if params[:file1].present?
    month = params[:billing_month]
   
    if month.present?
      fixed_day = 1
      selected_date = Date.new(Date.today.year, month.to_i, fixed_day) # Combina año, mes y día fijo
    else
      redirect_to uploaded_file_index_path, alert: "Mes inválido"
    end
    
    # Guardar las instancias
    if uploaded_file.save

      # process file depending on type
      if FileType.find_by(id: params[:file_type_id]).tag == "client_data"
        puts "client_data"
        import_client_data(uploaded_file.file)
      elsif FileType.find_by(id: params[:file_type_id]).tag == "measurement_dates"
        puts "measurement_dates"
        import_measuring_dates(uploaded_file.file, selected_date)
      elsif FileType.find_by(id: params[:file_type_id]).tag == "fees_table"
        puts "fees_table"
        import_fees_table(uploaded_file.file)
      end

      redirect_to uploaded_file_index_path, notice: "Archivos subidos con éxito."
    else
      redirect_to uploaded_file_index_path, alert: "Hubo un error al subir los archivos."
    end
  end

  def import_client_data(file) # meter todo esto en una transacción
    ActiveRecord::Base.transaction do
      csv_text = File.read(file)
      csv = CSV.parse(csv_text, :headers => true)
      csv.each do |row|
        client_number_field = row[0]
        client = Client.first_or_create(service_number: client_number_field)
        raise "Couldn't create client: #{client_number_field}" if meter.nil?
       
        meter_number_field = row[1]
        meter = Meter.first_or_create(meter_number: meter_number_field)
        
        client_meters = ClientMeter.where(client: client, meter: meter).first_or_create

        # Obtain Location and Group (lote) from "Route" field
        location_field = row[3][0..2]
        location = Location.find_by(number: location_field.to_i) # Location instances are created when fees table is read
        raise "Location not found: #{location_field}" if location.nil?

        group_field = row[3][3..5]
        group = Group.find_by(number: group_field.to_i) # Group instances are created when measurement_dates table is read
        raise "Group not found: #{group_field}" if group.nil?

        client.update(location: location, group: group)
        puts "#{client_number_field}, #{location_field}, #{group_field}"
      end
    end
  end

  # Imports measuring dates from CSV
  def import_measuring_dates(file, month)
    ActiveRecord::Base.transaction do
      month = Date.parse(month).change(day: 1) # billing month

      csv_text = File.read(args[:fn])
      csv = CSV.parse(csv_text, :headers => true)
      csv.each do |row|
        group_list = row[0].split(" - ") 
        raise "Bad formatting in group field: #{row[0]}" if group_list.length != 3

        group_list.each do |g|
          group = Group.where(number: g.to_i).first_or_create
          
          MeasurementDate.where(month: month).delete_all
          MeasurementDate.create!(group: group, last_date: Date.parse(row[1]), current_date: Date.parse(row[2]), month: month)
        end
      end
    end
  end
  
  # Import fees table
  def import_fees_table(file)
    ActiveRecord::Base.transaction do

      csv_text = File.read(args[:fn])
      csv = CSV.parse(csv_text, :headers => true)

      csv.each do |row|
        location = Location.find_by(code: row[7].to_i)
        if location.nil?
          location = Location.create(code: row[7].to_i, name: row[8])
        end

        location.update(base_fee: row[9].to_f, ap_fee: row[10].to_f, al_fee: row[11].to_f, tas_fee: row[12].to_f)
      end
    end
  end
end

