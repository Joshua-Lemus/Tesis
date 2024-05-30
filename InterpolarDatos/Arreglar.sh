#!/bin/bash
###############################################################
#Toma un archivo csv con valores xyz y lo convierte al
#formato .most
###############################################################

PRIMERARG=$1 #El primer argumento será el archivo que se desea "arreglar", con su path
ARCHIVO=${PRIMERARG##*/} #El nombre del archivo sin el path
FILEPATH=${PRIMERARG%/*} #El path del archivo (sin el nombre)
LIMPIO='limpio_'$ARCHIVO #Este archivo intermedio ordena cosas para que sea más fácil convertir de xyz a most (????)

echo "> El archivo es $ARCHIVO"

#Cambiar las comas por espacios, para facilitar la tarea de Matlab
echo "> Cambiando comas por espacios"
sed -e 's/,/\t/g' $PRIMERARG > $LIMPIO

#Eliminar header ("X Y Z")
echo "> Elminando header"
sed '/X/d' $LIMPIO > tmp && mv tmp $LIMPIO

### No recuerdo por que me parecia importante eliminar datos con nodata value. Posiblemente porque no sabia hacer recortes de los datos segun mis necesidades. Dejo esto comentado porque ahora me parece mas bien importante conservaro los datos con nodata value.
#Eliminar datos con nodata value
echo "> Eliminando datos con nodata value"
#sed -i '/\t0/d' $LIMPIO ###Nota: Deberia conservar los datos con elevacion 0
# sed -i '/\t-32768/d' $LIMPIO #El nodata value de gua_501
# sed -i '/\t-8888/d' $LIMPIO #El nodata value de GEBCO
# sed -i '/\t-3.40282e+38/d' $LIMPIO #El nodata value de GEBCO-DEM
# sed -i '/\t-340282000000000014192072600942972764160.000000/d' $LIMPIO #Otra vez GEBCO-DEM



#Convertir longitudes negativas a positivas (sumando 360)
###Nota: El que decia solo print es el original. No funcinó, pero no sé por qué
###Nota: Deberia primero asegurarse que las longitudes son negativas, porque puede que no lo sean. De momento todos los archivos que uso tienen longitudes negativas, asi que puedo saltarme ese paso y posiblemente implementarlo a futuro.
#awk '{$1 = 360+$1; print}' $LIMPIO > tmp && mv tmp $LIMPIO
echo "> Convirtiendo longitudes a positivas"
awk '{$1 = 360.0000000000000+$1; printf "%3.16f %3.16f %f\n", $1, $2, $3}' $LIMPIO > tmp && mv tmp $LIMPIO



#Correr el script de matlab
###Nota: Modificar la linea "file = fopen('limpio_datos.csv', 'r'); %This is the input file" para que tenga el nombre correcto en lugar de "limpio_datos.csv" 
sed -i "/This is the input file/c file = fopen('$LIMPIO', 'r'); %This is the input file" WriteMostGrid.m
# Si en algun momento arruino WriteMostGrid.m, recuperarlo con WriteMostGrid.bk5

echo "> Convirtiendo a formato .most"
octave WriteMostGrid.m 


### Por alguna razón, antes yo prefería mantener una copia temporal del archivo convertido. Ahora trabajo con archivos más grandes, así que prefiero no dejar copias.
#Copiar el archivo convertido (.most) al directorio con el archivo original (.csv) Nótese que habrán dos copias, pero una es temporal, porque el archivo Most_preuba.most existirá solamente hasta que se vuelva a correr WriteMostGrid.m
echo "> Copiando al directorio $FILEPATH"
# cp Most_prueba.most $FILEPATH/${ARCHIVO%".csv"}.most
mv Most_prueba.most $FILEPATH/${ARCHIVO%".csv"}.most
