#!/usr/bin/python
import numpy as np
import sys
import math

#mostGrid_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/nuevo_modelo_965-890_090-155_8.most"
mostGrid_path = "/home/joshy/ComMIT/scratch/SanJose_0001_GUANICA1/nuevo_modelo_960-895_.95-150_0001_16.most"
xyzGrid_path = "/home/joshy/Tareas/Tesisultima/inundacion/SanJose_0001_GUANICA1/nuevo_modelo_960-895_.95-150_0001_16.xyz"
#"/home/joshy/ComMIT/scratch/convertedGrids5/nuevo_modelo_9099-9074_1385-1410_1.xyz"
#xyzGrid_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/nuevo_modelo_965-890_090-155_8.xyz"

#-------------------------------------------------------------------------------
# Leer datos
#-------------------------------------------------------------------------------
### Arrays con latitudes y longitudes. Deberian ser iguales para DEM y para Bath
### Las elevaciones se guardan en elevs
lats=[]
lons=[]

with open(mostGrid_path,'r') as f:
    nx, ny = f.readline().split()
    nx = int(nx)
    ny = int(ny)
    print("nx, ny: ",nx,ny)
    ### Write list of lons
    for i in range (nx): #This will run from 0 to nx-1
        lons.append(round(float(f.readline()),3))
    print("> Rango de longitudes: ")
    print(lons[0], lons[nx-1])
    ### Write list of lats
    for i in range (ny): #This will run from 0 to ny-1
        lats.append(round(float(f.readline()),3))
    print("> Rango de latitudes: ")
    print(lats[0], lats[ny-1])
    ### Write matrix of elevations
    DEM_elevs = np.array([[0.0] * nx] * ny)
    for j in range(ny):    # ny lines left, each containing nx columns
        DEM_elevs[j] = np.array([float(z) for z in f.readline().split()])
    print('valores de DEM en [0][0] y en [ny-1][nx-1]: ', DEM_elevs[0][0], DEM_elevs[ny-1][nx-1])

    
#-------------------------------------------------------------------------------
# Llenar datos
#-------------------------------------------------------------------------------
lon_min = lons[0]
lon_max = lons[nx-1]
lat_max = lats[0]
lat_min = lats[ny-1]
Delta = round(lons[1]-lons[0],3)
Delta_lats = round(lats[0]-lats[1],3)
#print(Delta, Delta_lats)
if Delta_lats != Delta:
    sys.exit("El grid no es cuadrado")

lon=lon_min
# modelo_elevs=np.array([[0.000] * nx] * ny)
# print(lon, Lon0DEM)
# for i in range(nx):
#     #print i
#     lon=lons[i]
#     print(lon)
#     modelo_elevs[j][i]= DEM_elevs[j][i]

#-------------------------------------------------------------------------------
# Escribir datos
#-------------------------------------------------------------------------------

#En los archivos, la longitud va aumentando y la latitud va disminuyendo. Primero cambia longitud, luego latitud.
with open(xyzGrid_path,'w') as modelo:
    for j in range(ny):
        #linea=""
        for i in range(nx):
            # linea='{0:.3f} {1:.3f} {2:.3f}\n'.format(float(lons[i])-360.000, float(lats[j]), -float(DEM_elevs[j][i]) )
            #linea='{0:.8f} {1:.8f} {2:.8f}\n'.format(float(lons[i]), float(lats[j]), float(DEM_elevs[j][i])*-1.0 )
            linea='{0:.3f} {1:.3f} {2:.3f}\n'.format(float(lons[i]), float(lats[j]), float(DEM_elevs[j][i])*-1.0 )
            modelo.write(linea)
