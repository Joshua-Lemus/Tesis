#!/usr/bin/python
# -*- coding: utf-8 -*-

import numpy as np
import math

"""
Hacer grids uniformes.
Para correr, solo necesitas definir los parametros lon_min--Delta y los paths de los archivos de entrada y salida.
Si el grid se sale de los datos que existen en el archivo de entrada, igual deberia funcionar, pero no lo he probado.
"""
#-------------------------------------------------------------------------------
#  Definiciones
#-------------------------------------------------------------------------------
#data_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/toy_gebco_905-890_130-140.most"
data_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/toy_dem_905-895_130-140.most"
#gridded_data_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/gridded_toy_gebco_905-890_130-140.most"
gridded_data_path = "/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/gridded_toy_dem_905-890_130-140.most"
print("data path is", data_path)

lon_min = 360-90.5#-94.0 #(-96.5)
lon_max = 360-89.0#-92.5 #(-89.0)
lat_min = 13.0#10.5 #(9.0)
lat_max = 14.0#11.0 #(15.5)
Delta = 0.003#0.0028 #~300 metros ~ 10 arcsec ~ 0.0028 deg
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Funciones de distancia y búsqueda binaria
#-------------------------------------------------------------------------------
def distance(pt_1, pt_2):
    ''' Define distancia entre dos puntos. Usa el producto interno de la diferencia entre dos vectores (norma cuadrada), que es más eficiente que sacar la raíz cuadrada'''
    pt_1 = np.array((pt_1[0], pt_1[1]))
    pt_2 = np.array((pt_2[0], pt_2[1]))
    c=pt_1-pt_2 #Es más eficiente definir variable intermedia, o calcularla dos veces en la función? Supongo que depende de si quiero optimizar espacio (de memoria) o rapidez de cómputo.... ##Por ahi vi tambien que existen las lambda functions, que talvez resuelvan un poco esta duda....
    return np.inner(c,c) #La raíz cuadrada de esto sería la norma, pero a mí me basta con optimizar el producto interno ((x-y).T@(x-y))


def nearest(data, val):
    ''' Define algoritmo de búsqueda de las coordenadas en data más cercanas al punto (val) a escribir. Usa búsqueda binaria.'''
    lo, hi = 0, len(data) - 1
    best_ind = lo
    ### Los primeros valores (latitudes altas) son negativos, luego empiezan a ser positivos (latitudes bajas). Recordar que valores negativos indican altura positiva, y visceversa.
    while lo <= hi:
        mid = lo + (hi - lo) // 2
        if data[mid] < val:
            lo = mid + 1
            #print('hola')
        elif data[mid] > val:
            hi = mid - 1
            #print('bai')
        else:
            best_ind = mid
            break
        # check if data[mid] is closer to val than data[best_ind] 
        if abs(data[mid] - val) < abs(data[best_ind] - val):
            best_ind = mid
    return best_ind

# def binarySearch(list1, n):

#     low = 0  
#     high = len(elevs) - 1  
#     mid = 0 
  
#     while low <= high:  
#         # for get integer result   
#         mid = (high + low) // 2  
        
#         # Check if n is present at mid   
#         if list1[mid] < n:  
#             low = mid + 1  
            
#         # If n is greater, compare to the right of mid   
#         elif list1[mid] > n:  
#             high = mid - 1  
            
#         # If n is smaller, compared to the left of mid  
#         else:  
#             return mid  

    # return min(elevs.keys(), key=lambda x: distance(x, coord))
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Leer datos
#-------------------------------------------------------------------------------
### Arrays con latitudes y longitudes
### Las elevaciones se guardan en elevs
lats=[]
lons=[]

with open(data_path,"r") as f:
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
    #tmp_elevs = [[0] * nx] * ny
    elevs = [[0] * nx] * ny
    for j in range(ny):    # ny lines left, each containing nx columns
        # tmp_elevs = f.readline().split() #list with nx values
        elevs[j] = [float(z) for z in f.readline().split()]
        #elevs = np.asarray(tmp_elevs, dtype = np.float64, order ='C')
        # for i in range (nx):
        #     valor = float(tmp_elevs[i])
        #     elevs[j][i] = valor #float(tmp_elevs[i])
    print(elevs[0][3], elevs[ny-1][nx-1])
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Escribir datos
#-------------------------------------------------------------------------------

# Escribir primeras líneas 
nx = int(math.floor((lon_max - lon_min)/Delta) + 1)
ny = int(math.floor((lat_max - lat_min)/Delta) + 1)
    
lon = lon_min
lat = lat_max
with open(gridded_data_path,"w") as f:
    firstLine=' '+str(nx)+' '+str(ny)+'\n'
    f.write(firstLine)
    for countLon in range(nx):
        f.write('{0:.3f}\n'.format(lon))
        lon+=Delta 
    for countLat in range(ny):
        f.write('{0:.3f}\n'.format(lat))
        lat-=Delta
        
    lon = lon_min
    lat = lat_max
    reversedLats = [y for y in lats[::-1]]
    for counLatAgain in range(ny):
        j = nearest(reversedLats, lat) #Para cada linea, la latitud es la misma
        # print(lat, reversedLats[j], j)
        print(lat, lats[-j-1], j)
        for countLonAgain in range(nx):
            i = nearest(lons, lon)
            f.write('{0:.3f} '.format(elevs[-j-1][i]))
            print(lon, lons[i],i,elevs[-j-1][i])
            lon+=Delta
        lon = lon_min
        f.write('\n')
        lat-=Delta
        
print(len(lats))    


#-------------------------------------------------------------------------------
