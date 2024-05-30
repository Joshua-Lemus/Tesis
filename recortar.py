#!/usr/bin/python
# -*- coding: utf-8 -*-

import numpy as np
import math

"""
Recortar datos
"""

#-------------------------------------------------------------------------------
# Definiciones
#-------------------------------------------------------------------------------
datos_path="/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/modelo_965-890_090-155.most"
nuevo_modelo_path="/home/joshy/Documents/Trabajo/INSIVUMEH/DEM/Interpolados/nuevo_modelo_9099-9074_1385-1410_1.most"


minLat=13.85
maxLat=14.10
minLon=360-90.99
maxLon=360-90.74
fraction=1
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Funciones
#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Leer datos
#-------------------------------------------------------------------------------
lons=[]
lats=[]
with open(datos_path,"r") as datos:
    nx,ny=datos.readline().split()
    nx=int(nx)
    ny=int(ny)
    print("nx, ny: ",nx,ny)
    # Write list of lons
    for i in range (nx): #This will run from 0 to nx-1
        lons.append(round(float(datos.readline()),3))
    print("> Rango de longitudes originales: ")
    print(lons[0], lons[nx-1])
    # Write list of lats
    for i in range (ny): #This will run from 0 to ny-1
        lats.append(round(float(datos.readline()),3))
    print("> Rango de latitudes originales: ")
    print(lats[0], lats[ny-1])

    # Encontrar indices de minLat,maxLon, etc.
    reversedLats = [y for y in lats[::-1]]
    minLat_trueidx=ny-1-nearest(reversedLats, minLat)
    maxLat_trueidx=ny-1-nearest(reversedLats, maxLat)
    minLon_idx=nearest(lons, minLon)
    maxLon_idx=nearest(lons, maxLon)
    # Indices de minLat para lats
    #minLat_trueidx=ny-1+minLat_idx #
    #maxLat_trueidx=ny-1+maxLat_idx
    # Si (minLat_trueidx-maxLat_trueidx) no es multiplo de fraction, el ciclo va a terminar un punto antes
    hastaLon=maxLon_idx if ((maxLon_idx-minLon_idx)%fraction==0) else maxLon_idx-(maxLon_idx-minLon_idx)%fraction
    hastaLat=minLat_trueidx if ((minLat_trueidx-maxLat_trueidx)%fraction==0) else minLat_trueidx-(minLat_trueidx-maxLat_trueidx)%fraction
    # Valores de nx, ny
    new_nx=abs(hastaLon-minLon_idx)/fraction+1
    new_ny=abs(maxLat_trueidx-hastaLat)/fraction+1
    print("> rangos de latitud, rangos de longitud, new_nx y new_ny")
    # print(minLat_idx, maxLat_idx, minLon_idx, maxLon_idx, new_nx,new_ny)

    print("> Rango de longitudes nuevos: ")
    print(lons[minLon_idx], lons[hastaLon])
    print("> Rango de latitudes nuevos: ")
    # print(lats[minLat_idx-1], lats[maxLat_idx-1])
    print(lats[hastaLat], lats[maxLat_trueidx])
    # print(reversedLats[-minLat_idx], reversedLats[-maxLat_idx])



    
    # Saltarse lineas con valores anteriores a la latitud maxLat
    for j in range(maxLat_trueidx):
        datos.readline()
    #print('empezando por', datos.readline())
    
    # En líneas con valores entre maxLat y minLat
    maxLat_line=1+nx+ny+maxLat_trueidx+1
    minLat_line=1+nx+ny+minLat_trueidx+1
    print('> entre lineas ', maxLat_line, ' y ', minLat_line)
    elevs = [[0] * nx] * ny

    # new_elevs=[[0] * new_nx] * new_ny
    print('> Ahorita voy a escribir')
    
    with open(nuevo_modelo_path,'w') as nuevo:
        #-----------------------------------------------------------------------
        # Escribir datos
        #-----------------------------------------------------------------------
        #Primer linea
        firstLine=' '+str(new_nx)+' '+str(new_ny)+'\n'
        nuevo.write(firstLine)
        #longitudes
        for i in range(minLon_idx,hastaLon+1,fraction):
            nuevo.write('{0:.3f}\n'.format(float(lons[i])))
        #latitudes
        for j in range(maxLat_trueidx,hastaLat+1,fraction):
            nuevo.write('{0:.3f}\n'.format(float(lats[j])))
        # Leer las siguientes new_ny*fraction lineas. Escribir las que sean multiplos de fraction
        for j in range(new_ny*fraction):
            # Si es un número par (o cualsea fracción elegida), copiar línea
            if j%fraction==0:
                elevs[j] = [float(z) for z in datos.readline().split()]
                # Solo escribir cada fraction columna
                #print(j)
                for i in range(minLon_idx,hastaLon+1,fraction):
                    #print(i,str(elevs[-j][i]))
                    nuevo.write('{0:.3f} '.format(elevs[j][i]))
                nuevo.write('\n')
                # Si es un número impar (o no es la fracción elegida), saltar línea
            else:
                datos.readline()
            
