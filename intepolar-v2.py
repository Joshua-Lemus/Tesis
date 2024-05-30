#!/usr/bin/python
import numpy as np
import sys
import math

DEM_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/gridded_toy_dem_905-890_130-140.most"
Bat_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/gridded_toy_gebco_905-890_130-140.most"
Costa_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/toy_coastLine_905-890_130-140.mostcsv"

modelo_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/toy_model_905-890_130-140.most"

Lon0DEM=360.0-92.120#92.23
LonFinDEM=360-90.11
#-------------------------------------------------------------------------------
# Definicion de funciones
#-------------------------------------------------------------------------------

def interpolar(lat,lat_coast,lat_isoline,max_val):
    return ((max_val-0)/(lat_isoline-lat_coast))*(lat-lat_coast)

#-------------------------------------------------------------------------------
# Leer datos
#-------------------------------------------------------------------------------
### Arrays con latitudes y longitudes. Deberian ser iguales para DEM y para Bath
### Las elevaciones se guardan en elevs
lats=[]
lons=[]

with open(DEM_path,"r") as f:
    nx, ny = f.readline().split()
    nx = int(nx)
    ny = int(ny)
    print("nx, ny: ",nx,ny)
    # Write list of lons
    for i in range (nx): #This will run from 0 to nx-1
        lons.append(round(float(f.readline()),3))
    print("> Rango de longitudes: ")
    print(lons[0], lons[nx-1])
    # Write list of lats
    for i in range (ny): #This will run from 0 to ny-1
        lats.append(round(float(f.readline()),3))
    print("> Rango de latitudes: ")
    print(lats[0], lats[ny-1])
    # Write matrix of elevations
    DEM_elevs = np.array([[0] * nx] * ny)
    for j in range(ny):    # ny lines left, each containing nx columns
        DEM_elevs[j] = np.array([float(z) for z in f.readline().split()])
    print('valores de DEM en [0][0] y en [ny-1][nx-1]: ', DEM_elevs[0][0], DEM_elevs[ny-1][nx-1])

with open(Bat_path,"r") as f:
    Bat_nx, Bat_ny = f.readline().split()
    Bat_nx = int(nx)
    Bat_ny = int(ny)
    if (Bat_nx != nx or Bat_ny != ny):
        print("DEM y Bat deben tener los mismos datos!!!!!!!!!!!")
        sys.exit("DEM y Bat tienen diferente cantidad de datos")
    # Skip lons
    for i in range (nx): #This will run from 0 to ny-1
        f.readline()
    # Skip lats
    for j in range (ny): #This will run from 0 to ny-1
        f.readline()
    # Write matrix of elevations
    Bat_elevs = np.array([[0] * nx] * ny)
    for j in range(ny):    # ny lines left, each containing nx columns
        Bat_elevs[j] = np.array([float(z) for z in f.readline().split()])
    print('valores de Bat en [0][0] y en [ny-1][nx-1]: ', Bat_elevs[0][0], Bat_elevs[ny-1][nx-1])

lon_min = lons[0]
lon_max = lons[nx-1]
lat_max = lats[0]
lat_min = lats[ny-1]
Delta = round(lons[1]-lons[0],3)
Delta_lats = round(lats[0]-lats[1],3)
#print(Delta, Delta_lats)
if Delta_lats != Delta:
    sys.exit("El grid no es cuadrado")
    
costa_lats = np.array([0.0] * nx)
isoline_lats=np.array([0.0] * nx)
isoline_elevs=np.array([0.0]* nx)
with open(Costa_path,"r") as f:
    f.readline() #Skip header
    for i in range(nx):
        vals = f.readline().split(', ')
        costa_lats[i] = float(vals[3])
        isoline_lats[i] = float(vals[4])
        isoline_elevs[i]= float(vals[5])

print ('ultimos valores de costa e isolinea: ', lons[nx-1],costa_lats[nx-1],isoline_lats[nx-1],isoline_elevs[nx-1])

#-------------------------------------------------------------------------------
# Llenar datos
#-------------------------------------------------------------------------------
lon=lon_min
modelo_elevs=np.array([[0.000] * nx] * ny)
print(lon, Lon0DEM)
for i in range(nx):
    #print i
    lon=lons[i]
    print(lon)
    #Primeras longitudes: lons[0] hasta Lon0DEM; datos de Bat
    if lon <= Lon0DEM:
        for j in range(ny):
            modelo_elevs[j][i]= Bat_elevs[j][i]
        
    #Siguientes longitudes: de Lon0DEM a LonFinDEM; interpolar datos
    elif (lon > Lon0DEM and lon <= LonFinDEM  ):
        for j in range(ny):
            lat=lats[j]
            #Abajo de la costa, datos de Bat
            if lat < costa_lats[i]:
                modelo_elevs[j][i]=Bat_elevs[j][i]
            #Arriba de la linea de costa, no mayor a la isolinea de 15 metros: datos interpolados
            elif (lat > costa_lats[i] and lat <= isoline_lats[i]):
                modelo_elevs[j][i] = interpolar(lat, costa_lats[i],isoline_lats[i], isoline_elevs[i])
                print(modelo_elevs[j][i])
            #Arriba de la isolinea de 15 metros, datos de DEM
            elif lat > isoline_lats[i]:
                modelo_elevs[j][i] = DEM_elevs[j][i]
                print(modelo_elevs[j][i])
        #print(modelo_elevs[0][i])
                
    #Ultimas longitudes: despues de LonFinDEM; datos de Bat
    elif lon > LonFinDEM:
        #print(i, Bat_elevs[:][i].shape)
        #print(Bat_elevs[ny-1][i])
        for j in range(ny):
            modelo_elevs[j][i]= Bat_elevs[j][i]
        #print(modelo_elevs[54][i])
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Escribir datos
#-------------------------------------------------------------------------------
def escribirLinea(elevs):
    linea=""
    for elevacion in elevs:
        linea=linea+" "+str(elevacion)
    return linea


with open(modelo_path,'w') as modelo:
    #Primeras lineas: nx, ny, lons y lats
    firstLine=' '+str(nx)+' '+str(ny)+'\n'
    modelo.write(firstLine)
    for i in range(nx):
        modelo.write('{0:.3f}\n'.format(float(lons[i])))
    for j in range(ny):
        modelo.write('{0:.3f}\n'.format(float(lats[j])))
    for j in range(ny):
        #linea=""
        for i in range(nx):
            modelo.write('{0:.3f} '.format(modelo_elevs[j][i]))
            #linea=linea+str(modelo_elevs[j][i])+" "
        #linea=linea+"\n"
        #print(linea)
        modelo.write('\n')
