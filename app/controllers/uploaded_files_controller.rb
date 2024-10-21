require 'csv'    

class UploadedFilesController < ApplicationController
  def index
    @file_types = FileType.all
  end

  def upload_files
    uploaded_file = UploadedFile.new(file_type_id: params[:file_type_id])

    # Adjuntar archivos a cada instancia
    uploaded_file.file.attach(params[:file1]) if params[:file1].present?
    month = params[:billing_month]
   
    if FileType.find_by(id: params[:file_type_id]).tag == "measurement_dates"
      puts "MEASUREMENT DATES"
      if month.present?
        fixed_day = 1
        selected_date = Date.new(Date.today.year, month.to_i, fixed_day) # Combina año, mes y día fijo
      else
        redirect_to uploaded_file_index_path, alert: "Mes inválido"; return
      end
    end 

    # Guardar las instancias
    if uploaded_file.save
      #file_path = Rails.application.routes.url_helpers.rails_blob_path(uploaded_file.file, only_path: true)
      local_file_path = ActiveStorage::Blob.service.send(:path_for, uploaded_file.file.key)

      # process file depending on type
      if FileType.find_by(id: params[:file_type_id]).tag == "client_data"
        puts "client_data"
        errors = []
        errors = import_client_data(local_file_path)
        if errors.length > 0
            msg = "Archivo subido pero con errores: #{errors.join('\n')}"
        else
            msg = "Archivo subido con éxito"
        end
      elsif FileType.find_by(id: params[:file_type_id]).tag == "measurement_dates"
        puts "measurement_dates"
        import_measurement_dates(local_file_path, selected_date)
        msg = "Archivo subido con éxito"
      elsif FileType.find_by(id: params[:file_type_id]).tag == "fees_table"
        puts "fees_table"
        import_fees_table(local_file_path)
        msg = "Archivo subido con éxito"
      end

      redirect_to uploaded_file_index_path, notice: msg
    else
      redirect_to uploaded_file_index_path, alert: "Hubo un error al subir los archivos."
    end

  end

  def import_client_data(file) 
    csv_text = File.read(file)
    csv = CSV.parse(csv_text, :headers => true)

    errors = []

    puts "CSV file row count: #{csv.length}"
  
    csv.each do |row|
      client_number_field = row[0]
     
      # Obtain Location and Group (lote) from "Route" field
      location_field = row[3][0..2]
      location = Location.find_by(code: location_field.to_i) # Location instances are created when fees table is read
      if location.nil?
        errors.push("Couldn't create #{client_number_field} client because location #{location_field} doesn't exist in DB")
        next
      end

      group_field = row[3][3..5]
      group = Group.find_by(number: group_field.to_i) # Group instances are created when measurement_dates table is read
      if group.nil?
        errors.push("Couldn't create #{client_number_field} client because group #{group_field} doesn't exist in DB")
        next
      end

      applied_fee_type = AppliedFeeType.find_by(label: row[11])
      if applied_fee_type.nil?
        errors.push("Couldn't create #{client_number_field} client because fee type #{row[11]} doesn't exist in DB")
        next
      end

      client = Client.where(service_number: client_number_field).first_or_create
      client.update(location: location, group: group, route: row[3], client_name: row[6], address: row[7], applied_fee_type: applied_fee_type, phone_number: row[20], mobile_number: row[21], email: row[22], lat: row[28].to_f, long: row[29].to_f)
    end

    errors
  end

  # Imports easuring dates from CSV
  def import_measurement_dates(file, month)
    ActiveRecord::Base.transaction do
      MeasurementDate.where(month: month).delete_all
      
      csv_text = File.read(file)
      csv = CSV.parse(csv_text, :headers => true)
      csv.each do |row|
        group_list = row[0].split(" - ") 
        raise "Bad formatting in group field: #{row[0]}" if group_list.length != 3

        group_list.each do |g|
          group = Group.where(number: g.to_i).first_or_create
          
          MeasurementDate.create!(group: group, last_date: Date.parse(row[1]), current_date: Date.parse(row[2]), month: month)
        end
      end
    end
  end
  
  # Import fees table
  def import_fees_table(file)
    ActiveRecord::Base.transaction do

      csv_text = File.read(file)
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

