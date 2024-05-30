#!/usr/bin/python

import numpy as np

"""
Hacer grids uniformes.
Para correr, solo necesitas definir los parametros lon_min--Delta y los paths de los archivos de entrada y salida.
Si el grid se sale de los datos que existen en el archivo de entrada, igual deberia funcionar, pero no lo he probado.
"""

data_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/toy_gebco_905-890_130-140.csv"
#data_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/toy_dem_905-895_130-140.csv"
gridded_data_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/gridded_toy_gebco_905-890_130-140.csv"
#gridded_data_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/gridded_toy_dem_905-890_130-140.csv"

lon_min = -90.5#-94.0 #(-96.5)
lon_max = -89.0#-92.5 #(-89.0)
lat_min = 13.0#10.5 #(9.0)
lat_max = 14.0#11.0 #(15.5)
Delta = 0.1#0.0028 #~300 metros ~ 10 arcsec ~ 0.0028 deg

def distance(pt_1, pt_2):
    pt_1 = np.array((pt_1[0], pt_1[1]))
    pt_2 = np.array((pt_2[0], pt_2[1]))
    #(x-y).T@(x-y)
    return np.linalg.norm(pt_1-pt_2) ## Esto esta sacando la norma, solo necesito el producto punto



# def nearest(elevs, coord):
#     min(elevs.keys(), key=lambda x: distance(x, coord))

### Asignar diccionario con {(lon,lat):elev}
lats=[]
lons=[]
elevs = {}
with open(data_path,"r") as f:
    for line in f:
        x_data = float(line.split(",")[0])
        y_data = float(line.split(",")[1])
        z_data = float(line.split(",")[2].split('\n')[0])
        # if x_data not in lons:
        #     lons.append(x_data)
        # if y_data not in lats:
        #     lats.append(y_data)
        elevs[(x_data,y_data)]=z_data
        # Evitar diccionarios

# print( elevs[(-90.80307263, 14.49580745)])


## 
# def find_nearest(array, value):
#     array = np.asarray(array)
#     idx = (np.abs(array - value)).argmin()
#     return array[idx]


    
# def closest_z(datos, x, y):
#     x_data, y_data, z_data = datos.readline().split(",")
#     while ( float(x_data)<=x and float(y_data)>=y)
#     x_data, y_data, z_data = datos.readline().split(",")
#     if(x):
#         return z_data

#En los archivos, la longitud va aumentando y la latitud va disminuyendo. Primero cambia longitud, luego latitud.
lon = lon_min
lat = lat_max
with open(gridded_data_path,"w") as gridded_data:
    while lat >= lat_min:
        print("latitude ", lat)
        while lon <= lon_max:
            coord = (lon, lat)
            nearest = min(elevs.keys(), key=lambda x: distance(x, coord)) #Hacer búsqueda binaria
            #print(lon, lat, nearest, elevs[nearest])
            
            xyz ='{0:.2f}, {1:.2f}, {2}\n'.format(lon, lat, elevs[nearest]) # str(lon)+","+str(lat)+","+closest_z(data, lon, lat)#+'\n'
            print(xyz)
            gridded_data.write(xyz)
            lon+=Delta
        lat-=Delta
        lon=lon_min

# data.close()
# gridded_data.close()
