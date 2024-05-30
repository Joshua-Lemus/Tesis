#!/usr/bin/python

import sys
import math
import numpy as np

#-------------------------------------------------------------------------------
# Definiciones
#-------------------------------------------------------------------------------
DEM_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/gridded_toy_dem_905-890_130-140.most"
Bat_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/gridded_toy_gebco_905-890_130-140.most"
costa_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/toy_coastLine_905-890_130-140.mostcsv"


# lon_min = 360-90.5#-94.0 #(-96.5)
# lon_max = 360-89.0#-92.5 #(-89.0)
# lat_min = 13.0#10.5 #(9.0)
# lat_max = 14.0#11.0 #(15.5)
# Delta = 0.1 #0.00278 Delta de los datos ordenados
DEM_NANVal = -9223372036854775808#340282000000000014192072600942972764160.000
chosenIsoline = -15
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Definicion de funciones
#-------------------------------------------------------------------------------
### Encontrar la costa de Bat, definida como la latitud maxima a la que la elevacion pasa de ser negativa a ser positiva

def Bat_coast(elevs):
    ''' Define algoritmo de busqueda del indice en lats donde el valor de elevs pasa de ser negativo a ser positivo. Usa busqueda binaria. Se espera que los valores en lats esten ordenados con valores negativos primero y positivos despues'''
    val=0
    lo, hi = 0, len(elevs) - 1
    best_ind = lo
    while lo <= hi:
        mid = lo + (hi - lo) // 2
        if elevs[mid] < val:
            lo = mid + 1
            #print('hola')
        elif elevs[mid] > val:
            hi = mid - 1
            #print('bai')
        else:
            best_ind = mid
            break
        # check if elevs[mid] is closer to val than elevs[best_ind] 
        if abs(elevs[mid] - val) < abs(elevs[best_ind] - val):
            best_ind = mid
    return best_ind


##**En los archivos, la longitud va aumentando y la latitud va disminuyendo. Primero cambia longitud, luego latitud.
## Encontrar la costa de DEM. Definida como latitud maxima a la que la elevacion es igual a DEM_NANVal.
def DEM_coast(ordered_list):
    target=ordered_list[-1]
    left = 0
    right = len(ordered_list) - 1
    count = 0
    while left <= right:
        mid = (left + right) // 2
        count = count + 1
        if ordered_list[mid] == target:
            while mid > 0 and ordered_list[mid - 1] == target:
                mid = mid - 1
            return mid
        elif target < ordered_list[mid]:
            right = mid - 1
        else:
            left = mid + 1
    return None

def old_DEM_coast(elevs):
    ''' Define algoritmo de busqueda del indice en el que el valor de elevs pasa de ser negativo a ser DEM_NANVal. Usa busqueda binaria. Se espera que los valores en elevs esten ordenados con valores negativos primero y DEM_NANVal despues'''
    val = elevs[-1] #DEM_NANVal
    #print(val)
    lo, hi = 0, len(elevs) - 1
    best_ind = lo
    while lo < hi:
        mid = lo + (hi - lo) // 2
        if elevs[mid] == val:
            hi = mid
            #print('hola')
        elif elevs[mid] > val:
            lo = mid+1
            #mid=mid+1
        else:
            print("Raro")

            #print('bai')
        # if elevs[mid] > val:
        #     lo = mid + 1
        #     #print('hola')
        # elif elevs[mid] < val:
        #     hi = mid - 1
        #     #print('bai')
        # else:
        #     if elevs[mid-1] == val:
        #         #print(elevs[mid-1])
        #         hi = mid - 1
        #     else:
        #         #print("lol")
        #         #print(elevs[mid-1])
        #         best_ind = mid-1
        #         break
        # check if elevs[mid] is closer to val than elevs[best_ind] 
        if abs(elevs[mid] - val) < abs(elevs[best_ind] - val):
            best_ind = mid
    return best_ind

##**Para hallar la isolnea, empezar desde latitudes menores, para hallar el valor que este arriba de la isolinea. Esto porque en algunos casos el valor de abajo puede ser mar ya. Si ningun valor es mayor a chosenIsoline, devolver lat_max
def DEM_15m_isoline(elevs,DEMCoastLat_idx):
    ''' Define algoritmo de busqueda del indice en lats donde el valor de elevs pasa a ser -15'''
    val=chosenIsoline
    lo, hi = 0, DEMCoastLat_idx#len(elevs) - 1
    best_ind = lo
    while lo <= hi:
        mid = lo + (hi - lo) // 2
        if elevs[mid] < val:
            lo = mid + 1
            #print('hola')
        elif elevs[mid] > val:
            hi = mid - 1
            #print('bai')
        else:
            best_ind = mid
            break
        # check if elevs[mid] is closer to val than elevs[best_ind] 
        if abs(elevs[mid] - val) < abs(elevs[best_ind] - val):
            best_ind = mid
    return best_ind

#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Leer datos
#-------------------------------------------------------------------------------
### Arrays con latitudes y longitudes
### Las elevaciones se guardan en elevs
lats=[]
lons=[]

#def readData:
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
    print(nx,ny)
    # Write list of lons
    for i in range (nx): #This will run from 0 to ny-1
        lons.append(float(f.readline()))
    print("> Rango de longitudes: ")
    print(lons[0], lons[nx-1])
    # Write list of lats
    for i in range (ny): #This will run from 0 to ny-1
        lats.append(float(f.readline()))
    print("> Rango de latitudes: ")
    print(lats[0], lats[ny-1])
    # Write matrix of elevations
    DEM_elevs = np.array([[0] * nx] * ny)
    for j in range(ny):    # ny lines left, each containing nx columns
        DEM_elevs[j] = np.array([float(z) for z in f.readline().split()])
    print(DEM_elevs[0][0], DEM_elevs[ny-1][nx-1])

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
    for i in range (ny): #This will run from 0 to ny-1
        f.readline()
    # Write matrix of elevations
    Bat_elevs = np.array([[0] * nx] * ny)
    for j in range(ny):    # ny lines left, each containing nx columns
        Bat_elevs[j] = np.array([float(z) for z in f.readline().split()])
    print(Bat_elevs[0][0], Bat_elevs[ny-1][nx-1])

lon_min = lons[0]
lon_max = lons[nx-1]
lat_max = lats[0]
lat_min = lats[ny-1]
Delta = lons[1]-lons[0]
#-------------------------------------------------------------------------------


        
lon = lon_min
with open(costa_path,"w") as costa:
    header = "#longitude, DEM_coast, Bat_coast, Min(real)_coast, 15 m isoline latitude, elevation at 15m isoline\n"
    costa.write(header)
    print(header)
    x_range=int(math.floor((lon_max - lon_min)/Delta) + 1)
    print(DEM_elevs[:,0])
    for i in range(x_range):
        DEMCoastLat_idx = DEM_coast(DEM_elevs[:,i])
        DEMCoastLat =lats[DEMCoastLat_idx]
        BatCoastLat_idx = Bat_coast(Bat_elevs[:,i])
        BatCoastLat =lats[BatCoastLat_idx]
        isolineLat_idx = DEM_15m_isoline(DEM_elevs[:,i],DEMCoastLat_idx)
        isolineLat=lats[isolineLat_idx]
        ### Si el valor en la isolinea es DEM_NANVal, fijarla en 500. Si es mayor a 20, fijarla en 20.
        isolineOGVal=DEM_elevs[isolineLat_idx][i]
        if isolineOGVal == DEM_NANVal:
            isolineVal=-500
        elif isolineOGVal >= -20:
            isolineVal=isolineOGVal
        else:
            isolineVal=-20

        toWrite='{0:.3f}, {1:.3f}, {2:.3f}, {3:.3f}, {4:.3f}, {5}\n'.format(lon, DEMCoastLat ,BatCoastLat, min(DEMCoastLat, BatCoastLat), isolineLat, isolineVal)
        costa.write(toWrite)
        print(toWrite)
        lon=round(lon+Delta,3)


        
