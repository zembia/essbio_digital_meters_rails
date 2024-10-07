class UploadedFile < ApplicationRecord
  belongs_to :file_type # Asociación con el modelo FileType
  has_one_attached :file
end
