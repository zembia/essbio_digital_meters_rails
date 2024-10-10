import random
import math
import csv

def generate_coordinates(center_lat, center_lon, radius, count):
    coordinates = []

    for _ in range(count):
        # Generar un ángulo aleatorio
        angle = random.uniform(0, 360)
        
        # Calcular la distancia en radianes
        distance_in_radians = radius / 6371000.0  # Radio de la Tierra en metros

        # Calcular la nueva latitud
        new_lat = math.asin(math.sin(math.radians(center_lat)) * math.cos(distance_in_radians) +
                            math.cos(math.radians(center_lat)) * math.sin(distance_in_radians) * math.cos(math.radians(angle)))

        # Calcular la nueva longitud
        new_lon = math.radians(center_lon) + math.atan2(math.sin(math.radians(angle)) * math.sin(distance_in_radians) * math.cos(math.radians(center_lat)),
                                                          math.cos(distance_in_radians) - math.sin(math.radians(center_lat)) * math.sin(new_lat))

        # Convertir de radianes a grados
        new_lat = math.degrees(new_lat)
        new_lon = math.degrees(new_lon)

        coordinates.append((new_lat, new_lon))

    return coordinates

# Coordenadas centrales
center_lat = -36.82173260903037
center_lon = -73.05452415239712
radius = 2000  # en metros
count = 1612

# Generar las coordenadas
coordinates = generate_coordinates(center_lat, center_lon, radius, count)

# Imprimir las coordenadas
with open('coordinates.csv', mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Latitud', 'Longitud'])  # Escribir encabezados
    writer.writerows(coordinates)  # Escribir las coordenadas

