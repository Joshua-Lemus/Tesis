#!/usr/bin/python
#*-* coding: utf8 *-*

import numpy as np

# Definiciones
ver_pav = 17#'V'  # Solo hay vía vertical, camino pavimentado
hor_pav = 15#'H' # Solo hay vía horizontal, camino pavimentado
both_pav = 13#'D' #Cruce, camino pavimentado
ver_nopav = 27#'v' # Solo hay vía vertical, camino no pavimentado
hor_nopav = 25#'h' # Solo hay vía horizontal, camino no pavimentado
both_nopav = 23#'d' #Cruce, camino no pavimentado
ver_send = 57#'p'  # Solo hay vía vertical, camino pavimentado
hor_send = 55#'P' # Solo hay vía horizontal, camino pavimentado
both_send = 53#'q' #Cruce, camino pavimentado
ver_puente = 117#'r' #Puentes, se pueden caer
hor_puente = 115#'R' #Puentes, se pueden caer
bosque = 51#'f' #Puede que sean pastizales transitables, o puede que sean bosques impenetrables. Puede dársele un peso para que pocas personas se atrevan a atravesarlo, porque, en todo caso, los pastizales son propiedad privada, y no es fácil atravesarlos si no se conoce el camino.
agua = 105#'w'
sembrados = 67#'s'
playa =47#'b'

latmin=-91.1
latmax=-90.0

lonmin=260
lonmax=280

Delta=0.001

nx = 230 #(latmax-latmin)/Delta
ny = 25 #(lonmax-lonmin)/Delta


#raster= np.array([[books[author][genre] for genre in sorted(books[author])] for author in sorted(books)])

#vector = np.chararray((nx,ny))
vector = np.zeros((nx,ny), np.int16)
#vector[:][:]=''
print('hola', vector[229][24])


#----------------------------------------------------------------------
# Llenar valores de columnas 0 a 49, filas 0 a 12
#----------------------------------------------------------------------
# 0 a 13
vector[0:13, 0:3] = agua
#vector[0:2, 0:13] = agua
vector[0:13, 3:8] = sembrados
vector[0:13, 8] = hor_nopav
vector[0:13, 9:13] = bosque
vector[0:13,13:17]=sembrados
#
vector[0:2,17]=hor_send
vector[0:2,18:25]=sembrados
vector[2,17]=both_send
vector[2,18:25]=ver_send
#
vector[3,17:25]=sembrados
#
vector[4:10,17:25]=sembrados
#
vector[10:13,17]=sembrados
vector[10:13,18]=hor_send
vector[10:13,19:25]=sembrados


print(vector[0][0], agua)
# 13
vector[13,0:3]=agua
vector[13,3]=playa
vector[13,4:6]=both_nopav
vector[13,6:8]=sembrados
vector[13,8]=hor_nopav
vector[13,9:13]=sembrados
#
vector[13,13:15]=sembrados
vector[13,15:18]=ver_send
vector[13,18]=both_nopav
vector[13,19:25]=ver_nopav

# 14 a 31
vector[14:31,0:3]=agua
vector[14:31,3]=playa
vector[14:31,4]=hor_nopav
vector[14:31,5]=hor_nopav
vector[14:31,6:8]=sembrados
vector[14:31,8]=hor_nopav
vector[14:31,9:13]=bosque
vector[10:19,9:13]=sembrados
#
vector[14:28,13:17]=sembrados
vector[14:24,17:25]=sembrados
vector[24:28,17]=hor_send
vector[24:28,18:25]=sembrados
vector[28,13:15]=sembrados
vector[28,15:17]=ver_send
vector[28,17]=both_send
vector[28,18:25]=ver_send
vector[29:31,13:17]=sembrados
vector[29:31,17]=hor_send
vector[29:31,18:25]=sembrados

# 31
vector[31,0:9]=vector[13,0:9]
vector[31,4:6]=ver_puente
vector[31,9:13]=bosque
#
vector[31,13:17]=sembrados
vector[31,17]=hor_send
vector[31,18:25]=sembrados

# 32 a 34
vector[32:34,0:3]=agua
vector[32:34,3]=playa
vector[32:34,4]=hor_nopav
vector[32:34,5]=hor_nopav
vector[32:34,6:8]=sembrados
vector[32:34,8]=hor_nopav
vector[32:34,9:13]=bosque
#
vector[32:34,13:17]=sembrados
vector[32:34,17]=hor_send
vector[32:34,18:25]=sembrados

# 34
vector[34,0:3]=agua
vector[34,3]=playa
vector[34,4]=hor_nopav
vector[34,5]=both_nopav
vector[34,6]=ver_nopav
vector[34,7]=both_nopav
vector[34,8]=hor_nopav
vector[34,9:13]=bosque
vector[34,13:25] = vector[31,13:25]

# 35 a 37
vector[35:37,0:7]=agua
vector[35:37,7]=hor_nopav
vector[35:37,8]=hor_nopav
vector[35:37,9:13]=bosque
#
vector[35:37,13:25]=vector[32:34,13:25]

# 37
vector[37,0:13]=vector[34,0:13]
#
vector[37,13:25] = vector[31,13:25]

#38 a 42
vector[38:42,0:13]=vector[14:18,0:13]
vector[38:40,13:25]=vector[32:34,13:25]
vector[40:42,13:25]=vector[32:34,13:25]

# 42
vector[42,0:13]=vector[13,0:13] # 31 en lugar de 13
#
vector[42,13:17]=sembrados
vector[42,17]=both_pav
vector[42,18:25]=ver_pav


# 43 a 45
vector[43:45,0:13]=vector[14:16,0:13]
vector[43:45,13:17]=sembrados
vector[43:45,17]=hor_pav
vector[43:45,18:25]=sembrados

vector[45,0:6]=vector[42,0:6]
vector[45,6]=both_nopav
vector[45,6:8]=ver_nopav
vector[45,8]=both_nopav
vector[45,9:17]=ver_nopav
vector[45,17]=both_nopav
vector[45,18:25]=sembrados

# 45 a 50
vector[46:50,0:13]=vector[14:18,0:13]
vector[46:50,13:17]=sembrados
vector[46:50,17]=hor_pav
vector[46:50,18:25]=sembrados

# 50 a 64
vector[50:64,0:2]=agua
vector[50:64,2:4]=playa
vector[50:64,4]=agua #Del 4 en realidad se tiene acceso horizontal a playa, pero entre el 3 al 5 hay agua. Por eso pongo agua aqui
vector[50:64,5]=sembrados #Debe estar en el 5, para que se tenga acceso a el
vector[50:64,6]=bosque #Este si parece seer bosque 
vector[50:64,7:13]=sembrados
#
vector[50:54,13:25]=vector[46:50,13:25]
vector[54:58,13:25]=vector[46:50,13:25]
vector[58:62,13:25]=vector[46:50,13:25]
vector[62:64,13:25]=vector[46:48,13:25]

# 64 a 70
vector[64:70,0:3]=vector[50:56,0:3] # le quite playa para darle continuidad a ese espacio donde hay sembrados
vector[64:70,3]=hor_send
vector[64:70,4:13]=vector[50:56,4:13] # que siga la forma agua - sembrados - bosque - sembrados
vector[64:70,13:25]=vector[50:56,13:25]

# 70
vector[70,0]=agua
vector[70,1:2]=playa
vector[70,2]=ver_send
vector[70,3]=both_send
vector[70,4]=ver_send #llega hasta los primeros sembrados
vector[70,5:13]=vector[50,5:13] #luego sigue la forma anterior.
#
vector[70,13:17]=sembrados
vector[70,17]=hor_pav
vector[70,18:21]=sembrados
vector[70,21:25]=ver_send

#71 a 73
vector[71:73,0:13]=vector[64:66,0:13]
vector[71:73,13:25]=vector[64:66,13:25]

# 73
vector[73,0]=agua
vector[73,1:3]=playa
vector[73,3]=hor_send
vector[73,4]=agua 
vector[73,5]=sembrados
vector[73,6]=sembrados
vector[73,7]=sembrados
vector[73,8:10]=both_nopav
vector[73,10:12]=sembrados
vector[73,12]=hor_nopav
vector[73,13:16]=sembrados
vector[73,16]=both_nopav
vector[73,17]=both_pav
vector[73,18:25]=sembrados

# 74
vector[74,0]=agua
vector[74,1]=playa
vector[74,2]=ver_nopav
vector[74,3]=both_nopav
vector[74,4]=ver_puente
vector[74,5]=both_nopav
vector[74,6]=ver_nopav
# vector[74,7]=sembrados
vector[74,7]=ver_nopav
vector[74,8:10]=both_nopav
vector[74,10:12]=ver_nopav
vector[74,12:14]=both_nopav
vector[74,14:16]=ver_nopav
vector[74,16]=both_nopav
vector[74,17]=hor_pav
vector[74,18:25]=sembrados

#75
vector[75,0:5]=vector[73,0:5]
vector[75,5]=both_nopav
vector[75,6:8]=ver_nopav#sembrados
vector[75,8:16]=vector[74,8:16]
vector[75,16]=sembrados
vector[75,17]=hor_pav
vector[75,18:25]=sembrados

#76 a 85
vector[76:81,0:17]=agua
vector[76,6:17]=sembrados
vector[76,17]=hor_pav
vector[77,17]=hor_puente
#
vector[76,18:25]=sembrados
vector[77,18:25]=agua
vector[78:81,17]=hor_pav
vector[78:81,18:25]=sembrados

vector[81:84,0:9]=agua
vector[81:84,9:17]=sembrados
vector[81:84,17]=hor_pav
vector[81:84,18:25]=sembrados

vector[84,0:2]=playa
vector[84,2:4]=sembrados
vector[84,4:9]=bosque
vector[84,9:25]=vector[81,9:25]

#85
vector[85:86,0:2]=playa
vector[85:86,2]=sembrados
vector[85:86,3]=hor_nopav
#vector[0:13, 12:25] = 'x'
#vector[0:13, 10]='x'
#print(vector[0:30][:])

with open('evacuationGrid-v2.csv','w') as f:
    for i in range(25):
        for j in range(85):
            #f.write(' {0:3d} {1:3d} {2:3d},'.format(j,i-24, vector[j, i]))
            f.write(' {0:3d} {1:3d} {2:3d}\n'.format(j,i-24, vector[j, i]))
        # f.write('\n')
        #f.write(" {0:3d} {1:3d} {2:2d}\n".format(0, 0-25, vector[0,0]))
