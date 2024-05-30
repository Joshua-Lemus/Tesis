#!/usr/bin/python

DEM_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/gridded_toy_dem_905-890_130-140.csv"
Bat_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/gridded_toy_gebco_905-890_130-140.csv"
costa_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/toy_coastLine_905-890_130-140.csv"


lon_min = -90.5#-94.0 #(-96.5)
lon_max = -89.0#-92.5 #(-89.0)
lat_min = 13.0#10.5 #(9.0)
lat_max = 14.0#11.0 #(15.5)
Delta = 0.1 #0.00278 Delta de los datos ordenados
DEM_NANVal = -3.40282e+38
chosenIsoline = 15

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

##**En los archivos, la longitud va aumentando y la latitud va disminuyendo. Primero cambia longitud, luego latitud.
## Encontrar la costa de DEM. Definida como latitud maxima a la que la elevacion es igual a DEM_NANVal.
def DEM_coast(lon):
    lat=lat_max
    while lat >= lat_min:
        print("todo bien")
        if DEM_elevs[(lon,lat)] == DEM_NANVal:
            return lat
        lat=round(lat-Delta,2)
    return lat_max #Si nunca llega a serlo, devolver lat_max

### Encontrar la costa de Bat, definida como la latitud maxima a la que la elevacion pasa de ser positiva a ser negativa
def Bat_coast(lon):
    lat=lat_max
    while lat >= lat_min:
        if Bat_elevs[(lon,lat)] <= 0:
            return lat
        lat=round(lat-Delta,2)

##**Para hallar la isolnea, empezar desde latitudes menores, para hallar el valor que este arriba de la isolinea. Esto porque en algunos casos el valor de abajo puede ser mar ya. Si ningun valor es mayor a chosenIsoline, devolver lat_max
def DEM_15m_isoline(lon):
    lat=lat_min
    while lat <= lat_max:
        if DEM_elevs[(lon,lat)] >= chosenIsoline:
            return lat
        lat=round(lat+Delta,2)
    return lat_max
        
lon = lon_min
with open(costa_path,"w") as costa:
    costa.write("longitude, DEM_coast, Bat_coast, Min(real)_coast, 15 m elevation isoline, elevation at 15m isoline\n")
    while lon <= lon_max:
        DEMCoastLat = DEM_coast(lon)
        BatCoastLat = Bat_coast(lon)
        isolineLat = DEM_15m_isoline(lon)
        ### Si el valor en la isolinea es DEM_NANVal, fijarla en 500. Si es mayor a 20, fijarla en 20.
        isolineOGVal=DEM_elevs[(lon,isolineLat)]
        if isolineOGVal == DEM_NANVal:
            isolineVal=500
        elif isolineOGVal <= 20:
            isolineVal=isolineOGVal
        else:
            isolineVal=20

        toWrite='{0:.2f}, {1:.2f}, {2:.2f}, {3:.2f}, {4:.2f}, {5}\n'.format(lon, DEMCoastLat , BatCoastLat, min(DEMCoastLat, BatCoastLat), isolineLat, isolineVal)
        costa.write(toWrite)
        print(toWrite)
        lon=round(lon+Delta,2)


        
