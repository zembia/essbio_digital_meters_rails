# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#

App.delete_all

App.create(name: "Essbio", tag: "essbio")
App.create(name: "Nuevo Sur", tag: "nuevo_sur")

NotificationType.create(name: "Fuga de agua", tag: "leakage")
AlertType.create(name: "Leakage", tag: "leakage")

Notification.create(notification_type: NotificationType.find_by(tag: "leakage"), message: "Su medidor reporta una posible fuga de agua.", level: 1)
Notification.create(notification_type: NotificationType.find_by(tag: "leakage"), message: "Su medidor sigue reportando una posible fuga de agua.", level: 2)
Notification.create(notification_type: NotificationType.find_by(tag: "leakage"), message: "Su medidor sigue reportando una posible fuga de agua por tercer día consecutivo.", level: 3)

