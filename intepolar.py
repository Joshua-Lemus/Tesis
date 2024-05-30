#!/usr/bin/python

DEM_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/gridded_toy_dem_910-900_136-145.csv"
Bat_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/gridded_toy_gebco-910-900_120-145.csv"
Costa_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/toy_coastLine.csv"

modelo_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/toy_model.csv"


lon_min = -91.0#-94.0 #(-96.5)
lon_max = -90.0#-92.5 #(-89.0)
lat_min = 13.5#10.5 #(9.0)
lat_max = 14.5#11.0 #(15.5)
Delta = 0.1

DEM_elevs = {}
## Read dem data
with open(DEM_path,"r") as f:
    for line in f:
        DEM_x = round(float(line.split(",")[0]),2)
        DEM_y = round(float(line.split(",")[1]),2)
        DEM_z = float(line.split(",")[2].split('\n')[0])
        DEM_elevs[(DEM_x,DEM_y)]=DEM_z

Bat_elevs = {}
## Read bat data
with open(Bat_path,"r") as f:
    for line in f:
        Bat_x = round(float(line.split(",")[0]),2)
        Bat_y = round(float(line.split(",")[1]),2)
        Bat_z = float(line.split(",")[2].split('\n')[0])
        Bat_elevs[(Bat_x,Bat_y)]=Bat_z

Costa = {}
isoline = {}
with open(Costa_path,"r") as f:
    f.readline()
    for line in f:
        lon = round(float(line.split(",")[0]),2)
        Costa_y = round(float(line.split(",")[3]),2)
        lat_isoline = round(float(line.split(",")[4]),2)
        max_elev = float(line.split(",")[5])
        Costa[lon] = Costa_y
        isoline[lon] = (lat_isoline, max_elev)


def interpolar(lat,lat_min,lat_isoline,max_val):
    return ((max_val-0)/(lat_isoline-lat_min))*(lat-lat_min)

        
#En los archivos, la longitud va aumentando y la latitud va disminuyendo. Primero cambia longitud, luego latitud.
lon = lon_min
lat = lat_max
with open(modelo_path,"w") as modelo:
    while lon <= lon_max:
        print("longitude ", lon)
        while lat >= lat_min:
            #Abajo de la costa, datos de GEBCO
            if lat < Costa[lon]:
                xyz ='{0:.2f}, {1:.2f}, {2}\n'.format(lon, lat, Bat_elevs[(lon,lat)])
                modelo.write(xyz)
                print(xyz)
            #En la linea de costa, 0
            elif lat == Costa[lon]:
                xyz ='{0:.2f}, {1:.2f}, {2}\n'.format(lon, lat, 0)
                modelo.write(xyz)
                print(xyz)
            #Arriba de la linea de costa, no mayor a la isolinea de 15 metros: datos interpolados
            elif (lat > Costa[lon]) and (lat <= isoline[lon][0]) :
                xyz ='{0:.2f}, {1:.2f}, {2}\n'.format(lon, lat, interpolar(lat, Costa[lon],isoline[lon][0], 15) )#isoline[lon][1]) )
                modelo.write(xyz)
                print(xyz)
            #Arriba de la isolinea de 15 metros, datos de DEM
            elif lat > isoline[lon][0]:
                xyz ='{0:.2f}, {1:.2f}, {2}\n'.format(lon, lat, DEM_elevs[(lon,lat)] )
                modelo.write(xyz)
                print(xyz)
            lat=round(lat-Delta,2)
        lon=round(lon+Delta,2)
        lat=lat_max
                
