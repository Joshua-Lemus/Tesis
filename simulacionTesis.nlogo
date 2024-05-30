extensions [csv nw vid]

globals [ data total-escombros salvados visual-field  ; panic-av panic-std av-evac-start std-evac-start visibilidad
  asphalted-speed asphalted-speed-stdev beach-speed beach-speed-stdev ; evacuees-population
  optimal-evacuees semirandom-evacuees followers-evacuees
  pavs no-pavs senderos bosques sembrados puentes playas
]

breed [nodes node]
breed [evacuees evacuee]

evacuees-own [ max-speed time-to-begin-evacuation panic]
links-own [ weight ]

to setup
  ;; Borrar datos de simulaciones pasadas y definir valores por defecto del mundo
  clear-all ;; Borrar datos almacenados de simulaciones pasadas
  file-close-all ;; Cerrar cualquier archivo de simulaciones pasadas
  resize-world 0 84 -24 0 ;; El (0,0) se coloca en la esquina superior izquierda por compatibilidad con el archivo CellInundations-v2.csv
  set-default-shape links "short" ;; Links cortos para facilitar su visualizacion
  set-default-shape turtles "default"
  ;vid:start-recorder
  ;vid:movie-open "/home/joshy/Tareas/Tesisultima/Evacuacion/Resultados/vid:record-interface.mp4"

  ;; definiciones de variables globales
  set visual-field 120  ;; Schmitz(2019)
  set asphalted-speed 0.53 ;; Sulaeman_etal(2013)
  set asphalted-speed-stdev 0.06 ;; Sulaeman_etal(2013)
  set beach-speed 0.71 ;; Sulaeman_etal(2013)
  set beach-speed-stdev 0.20 ;; Sulaeman_etal(2013)
  ;set evacuees-population 1000
  set total-escombros 0
  ; inicializar contador de agentes salvados
  set salvados 0

  ;; Inicializar numeros aleatorios
  let run-seed new-seed
  random-seed run-seed ;90071977
  ;show run-seed
  ;random-seed 26146410 ;; for testing

  ;; Inicializar el medio: celdas y links con pesos entre celdas
  no-display ;; apagar las actualizaciones visuales mientras se carga la configuracion del mundo (consumen muchos recursos)
  load-world ;; cargar colores de celdas
  initialize-evacuees ;; inicializar agentes evacuadores
  initialize-nodes ;; inicializar nodos y links
  display ;; encender las actualizaciones visuales

  ;; Abrir archivo con datos de inundacion, este se leera linea por linea en "go"
  file-open "CellInundations-v2.csv";

  ;; Iniciar conteo del tiempo
  reset-ticks ;; 1 tick = 32 s
end

to go
  ;;; Definir condicion para terminar el ciclo y subprocesos que ocurren al final de la simulacion
  if file-at-end? [ ;; El ciclo termina cuando se termina de leer los datos de inundacion
    set salvados (salvados + count evacuees) ;; Contar personas que siguen vivas dentro de las personas salvadas
    show timer ;; Imprimir contador
    vid:save-recording "/home/joshy/Tareas/Tesisultima/Evacuacion/Resultados/vid:record2.mp4"
    stop ;; Terimnar
  ]
  ;vid:record-source
  vid:record-interface
  ;vid:record-view
  ;;; Leer una linea de los datos de inundacion
  set data csv:from-row file-read-line ;; Cargar datos del archivo
  load-inundation ;; Usar los datos del archivo en el modelo

  ;;; Sacar agentes ahogados
  ask ( evacuees with [ ([pcolor] of patch-here) = 92 ] ) [die] ;; los agentes se ahogan cuando los alcanza una inundacion de un metro

  ;;; Definir rapidez de cada agente
  ask evacuees [
    set-speed
    if-else ( ticks >= time-to-begin-evacuation ) [  ;; si el agente no ha iniciado la evacuacion, su rapidez es 0
      if ( any? ((patches with [pcolor = 85]) in-radius 2) ) [ set max-speed max-speed + 0.2 ] ;; si el agente ve la inundacion cerca, aumenta su rapidez
    ]
    [ set max-speed 0 ]
  ]

  ;;; Mover agentes que siguen evacuacion optima
  if (any? optimal-evacuees) [
    ask (optimal-evacuees) [
      move-efficiently
    ]
  ]

  ;;; Mover agentes que siguen evacuacion semi-aleatoria
  if (any? semirandom-evacuees) [
    ask semirandom-evacuees [
      move-semirandom
    ]
  ]

  ;;; Mover agentes que siguen a personas con chaleco
    if (any? followers-evacuees) [
      ask followers-evacuees [
        move-followers
    ]
  ]

  ;;; Avanzar un tick
  tick
end

to load-world
  file-open "evacuationGrid-v2.csv"  ;; el archivo con datos de tipo de terreno
  set data csv:from-file "evacuationGrid-v2.csv" ;; leer el archivo

  ;;; cada linea del archivo contiene una columna con la posicion x de una celda,
  ;;;otra columna con su posicion y, y otra columna con el color que le corresponde segun el tipo de terreno
  foreach data [ points ->       ;; leer liqnea por linea linea
    foreach points [ values ->   ;; leer los caracteres de cada linea
      let the-x substring values 1 4      ;; los caracteres del 1 al 4 contienen la posicion x de la celda
      let the-y substring values 5 8      ;; los caracteres del 5 al 8 contienen la posicion x de la celda
      let the-color substring values 9 12 ;; los caracteres 9 al 12 contienen el color de la celda
      set the-x read-from-string the-x    ;; es necesario convertir los caracteres a números
      set the-y read-from-string the-y
      set the-color read-from-string  the-color
      ask patch (the-x) (the-y) [set pcolor the-color] ] ]  ;; asignarle un color a la celda (x,y)

  file-close ;; cerrar el archivo
end


to initialize-evacuees
  ;;; coloca evacuadores segun una distribucion semi-aleatoria
  ;;; lugares con camino (areas urbanas), 31% del total
  let n evacuees-population / 100
;  ask n-of ((evacuees-population * 0.1)) ( patches with [11 < pcolor and pcolor < 19] ) [ sprout-evacuees n ] ;; 10% en celdas rojas (pavimentado)
;  ask n-of (evacuees-population * 0.1) ( patches with [21 < pcolor and pcolor < 29] ) [ sprout-evacuees n ] ;; 10 in celdas anaranjadas (no pavimentado)
;  ask n-of (evacuees-population * 0.1) ( patches with [51 < pcolor and pcolor < 59] ) [ sprout-evacuees n ] ;; 10 in celdas verde lima (vereda)
;  ask n-of (evacuees-population * 0.01) ( patches with [111 < pcolor and pcolor < 119] ) [ sprout-evacuees n ] ;; 1 en celdas moradas (puentes)
;  ;;; lugares con vegetacion, 35% del total
;  ask n-of (evacuees-population * 0.05) ( patches with [ pcolor = 51] ) [ sprout-evacuees n ] ;; 5% en celdas verde musgo (bosque)
;  ask n-of (evacuees-population * 0.3) ( patches with [61 < pcolor and pcolor < 69] ) [ sprout-evacuees n ] ;; 30% en celdas verde lima (sembrados)
;  ;;; Costa, 34% del total
;  ask n-of (evacuees-population - (count evacuees) ) ( patches with [41 < pcolor and pcolor < 49] ) [ sprout-evacuees n ] ;; El resto (34%) en celdas verde musgo (playa)

  ask n-of (10) ( patches with [11 < pcolor and pcolor < 19] ) [ sprout-evacuees n ] ;; 10% en celdas rojas (pavimentado)
  ask n-of (10) ( patches with [21 < pcolor and pcolor < 29] ) [ sprout-evacuees n ] ;; 10 in celdas anaranjadas (no pavimentado)
  ask n-of (10) ( patches with [51 < pcolor and pcolor < 59] ) [ sprout-evacuees n ] ;; 10 in celdas verde lima (vereda)
  ask n-of (1) ( patches with [111 < pcolor and pcolor < 119] ) [ sprout-evacuees n ] ;; 1 en celdas moradas (puentes)
  ;;; lugares con vegetacion, 35% del total
  ask n-of (5) ( patches with [ pcolor = 51] ) [ sprout-evacuees n ] ;; 5% en celdas verde musgo (bosque)
  ask n-of (30) ( patches with [61 < pcolor and pcolor < 69] ) [ sprout-evacuees n ] ;; 30% en celdas verde lima (sembrados)
  ;;; Costa, 34% del total
  ask n-of (34) ( patches with [41 < pcolor and pcolor < 49] ) [ sprout-evacuees n ] ;; El resto (34%) en celdas verde musgo (playa)

  ;;; Darle parametros individuales a cada evacuador
  ask evacuees [
    set color blue ;; todos inician teniendo color azul
    set panic ( random-normal panic-av panic-std) ;; asignar un valor de panico a cada evacuador, siguiendo distribucion gaussiana con media panic-av y des. est. panic'std
    if ( panic < 0 ) [ set panic 0 ]              ;; panic es un porcentaje, no puede ser menor que 0.
    if ( panic > 1 ) [ set panic 1 ]              ;; panic es un porcentaje, no puede ser mayor que 1.
    set time-to-begin-evacuation ( random-normal av-evac-start std-evac-start ) ;; asignar un valor de tiempo de inicio de evacuacion a cada evacuador, distribuido tambien con una gaussiana
  ]

  ;;; Asignarle roles a cada evacuador
  set optimal-evacuees (n-of (evacuees-population * trained_persons ) evacuees) ;; porcentaje de evacuadores optimos dado por la variable trained_persons
  ask optimal-evacuees [ set color green ] ;; a los evacuadores optimos se les asigna el color verde
  set followers-evacuees ( n-of (evacuees-population * ( (1.0 - trained_persons) / 2.0 ) ) (evacuees with [color = blue]) ) ;; la mitad del resto seran seguidores
  ask followers-evacuees [ set color yellow ] ;; a los evacuadores seguidores se les asigna el color amarillo
  set semirandom-evacuees ( evacuees with [color = blue] ) ; los que no son optimal ni followers son semi-aleatorios
  ask semirandom-evacuees [ set color orange ] ;; a los evacuadores semi-aleatorios se les asigna el color anaranjado

end

to initialize-nodes
  ;;; elegir una forma visual para los nodos, en caso sea necesario verlos
  set-default-shape nodes "box" ;; la forma "box" facilita su visualizacion

  ;;; generar escombros por terremoto (trabajo a futuro)
;  ask (n-of total-escombros patches)[
;    set pcolor black
;    ask (turtles-here)[ die ]
;  ]

  ;;; crear los nodos, y asignarles un color (los links se asignaran segun el color de los nodos)
  ask patches [
  sprout-nodes 1 [     ;; un nodoo en cada celda
    set color pcolor   ;; el nodo tiene el color de la celda
      set hidden? true ;; ocultar nodos (verlos consume recursos computacionales)
    ]
  ]

  ;;; Definir tipos de nodos segun el tipo de terreno que representan
  set pavs (nodes with [11 < color and color < 19])                  ;; camino pavimentado
  set no-pavs turtle-set (nodes with [21 < pcolor and pcolor < 29])  ;; camino no pavimentado
  set senderos nodes with [51 < pcolor and pcolor < 59]              ;; senderos
  set bosques nodes with [ pcolor = 51]                              ;; terreno boscoso
  set sembrados nodes with [61 < pcolor and pcolor < 69]             ;; terreno con siembras
  set puentes nodes with [111 < pcolor and pcolor < 119]             ;; puentes
  set playas nodes with [41 < color and color < 49]                  ;; playas

  ;;; definir valores de pesos para los links,
  ;;; segun que tan conveniente se considere pasar de una celda a la otra
  let muy-conveniente 1
  let conveniente 2
  let normal 3
  let inconveniente 5
  let riesgoso 7
  let extremo 10

  ;;; asignar valores a links que salen de caminos pavimentados (hacia sus vecinos)
  ask pavs [
    ask ( (nodes-on neighbors4) with [member? self pavs] ) [ create-link-from myself      ;; hacia camino pavimentados, muy convenients
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self no-pavs] ) [ create-link-from myself   ;; hacia camino no pavimentados, inconveniente
      [set weight inconveniente] ]
    ask ( (nodes-on neighbors4) with [member? self senderos] ) [ create-link-from myself  ;; hacia senderos, inconveniente
      [set weight inconveniente] ]
    ask ( (nodes-on neighbors4) with [member? self bosques] ) [ create-link-from myself   ;; hacia bosques, extremo
      [set weight extremo] ]
    ask ( (nodes-on neighbors4) with [member? self sembrados] ) [ create-link-from myself ;; hacia siembras, riesgoso
      [set weight riesgoso] ]
    ask ( (nodes-on neighbors4) with [member? self puentes] ) [ create-link-from myself   ;; hacia puentes, normal
      [set weight normal] ]
    ask ( (nodes-on neighbors4) with [member? self playas] ) [ create-link-from myself    ;; hacia playas, extremo
      [set weight extremo] ]
  ]
  ask links [ set hidden? true ]  ;; ocultar links (verlos utiliza muchos recursos computacionales)

  ;;; asignar valores a links que salen de caminos no pavimentados (hacia sus vecinos)
  ask no-pavs [
    ask ( (nodes-on neighbors4) with [member? self pavs] ) [ create-link-from myself      ; con pavimentados
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self no-pavs] ) [ create-link-from myself   ; con no pavimentados
      [set weight normal] ]
    ask ( (nodes-on neighbors4) with [member? self senderos] ) [ create-link-from myself  ; con senderos
      [set weight inconveniente] ]
    ask ( (nodes-on neighbors4) with [member? self bosques] ) [ create-link-from myself   ; con bosques
      [set weight extremo] ]
    ask ( (nodes-on neighbors4) with [member? self sembrados] ) [ create-link-from myself ; con sembrados
      [set weight riesgoso] ]
    ask ( (nodes-on neighbors4) with [member? self puentes] ) [ create-link-from myself   ; con puentes
      [set weight normal] ]
    ask ( (nodes-on neighbors4) with [member? self playas] ) [ create-link-from myself   ; con playas
      [set weight inconveniente] ]
  ]
  ask links [ set hidden? true ]

  ask senderos [
    ask ( (nodes-on neighbors4) with [member? self pavs] ) [ create-link-from myself      ; con pavimentados
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self no-pavs] ) [ create-link-from myself   ; con no pavimentados
      [set weight conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self senderos] ) [ create-link-from myself  ; con senderos
      [set weight normal] ]
    ask ( (nodes-on neighbors4) with [member? self bosques] ) [ create-link-from myself   ; con bosques
      [set weight extremo] ]
    ask ( (nodes-on neighbors4) with [member? self sembrados] ) [ create-link-from myself ; con sembrados
      [set weight inconveniente] ]
    ask ( (nodes-on neighbors4) with [member? self puentes] ) [ create-link-from myself   ; con puentes
      [set weight normal] ]
    ask ( (nodes-on neighbors4) with [member? self playas] ) [ create-link-from myself   ; con playas
      [set weight inconveniente] ]
  ]
  ask links [ set hidden? true ]

  ask bosques [
    ask ( (nodes-on neighbors4) with [member? self pavs] ) [ create-link-from myself      ; con pavimentados
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self no-pavs] ) [ create-link-from myself   ; con no pavimentados
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self senderos] ) [ create-link-from myself  ; con senderos
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self bosques] ) [ create-link-from myself   ; con bosques
      [set weight inconveniente] ]
    ask ( (nodes-on neighbors4) with [member? self sembrados] ) [ create-link-from myself ; con sembrados
      [set weight conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self playas] ) [ create-link-from myself   ; con playas
      [set weight conveniente ] ]
  ]
  ask links [ set hidden? true ]

  ask sembrados [
    ask ( (nodes-on neighbors4) with [member? self pavs] ) [ create-link-from myself      ; con pavimentados
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self no-pavs] ) [ create-link-from myself   ; con no pavimentados
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self senderos] ) [ create-link-from myself  ; con senderos
      [set weight conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self bosques] ) [ create-link-from myself   ; con bosques
      [set weight riesgoso] ]
    ask ( (nodes-on neighbors4) with [member? self sembrados] ) [ create-link-from myself ; con sembrados
      [ set hidden? true
        set weight normal ] ]
;    ask ( (nodes-on neighbors4) with [member? self puentes] ) [ create-link-from myself   ; con puentes
;      [set weight 1] ]
    ask ( (nodes-on neighbors4) with [member? self playas] ) [ create-link-from myself   ; con playas
      [set weight normal] ]
  ]
  ask links [ set hidden? true ]

  ask puentes [
    ask ( (nodes-on neighbors4) with [member? self pavs] ) [ create-link-from myself      ; con pavimentados
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self no-pavs] ) [ create-link-from myself   ; con no pavimentados
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self senderos] ) [ create-link-from myself  ; con senderos
      [set weight muy-conveniente] ]
;    ask ( (nodes-on neighbors4) with [member? self bosques] ) [ create-link-from myself   ; con bosques
;      [set weight 1] ]
;    ask ( (nodes-on neighbors4) with [member? self sembrados] ) [ create-link-from myself ; con sembrados
;      [set weight 1] ]
    ask ( (nodes-on neighbors4) with [member? self puentes] ) [ create-link-from myself   ; con puentes
      [set weight normal] ]
  ]
  ask links [ set hidden? true ]

  ask playas [
    ask ( (nodes-on neighbors4) with [member? self pavs] ) [ create-link-from myself      ; con pavimentados
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self no-pavs] ) [ create-link-from myself   ; con no pavimentados
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self senderos] ) [ create-link-from myself  ; con senderos
      [set weight muy-conveniente] ]
    ask ( (nodes-on neighbors4) with [member? self bosques] ) [ create-link-from myself   ; con bosques
      [set weight extremo] ]
    ask ( (nodes-on neighbors4) with [member? self sembrados] ) [ create-link-from myself ; con sembrados
      [set weight conveniente] ]
;    ask ( (nodes-on neighbors4) with [member? self puentes] ) [ create-link-from myself   ; con puentes
;      [set weight 1] ]
    ask ( (nodes-on neighbors4) with [member? self playas] ) [ create-link-from myself   ; con playas
      [set weight inconveniente] ]
  ]
  ask links [ set hidden? true ]

  ;;; Romper links entre celdas inconectadas
  ask (nodes with [color = 25]) [ ;; Entre celdas caminos horizontales adyacentes
    ask my-links with [ (member? other-end no-pavs) and ([ycor] of other-end) = [ycor] of myself + 1 ] [
      die
    ]
  ]

  ask (nodes with [color = 27]) [ ;; Entre celdas caminos horizontales adyacentes
    ask my-links with [ (member? other-end no-pavs) and ([xcor] of other-end) = [xcor] of myself + 1 ] [
      die
    ]
  ]

  ask (nodes with [color = blue]) [ ;; Entre celdas con agua
    die
  ]

  ask (nodes with [color = black]) [ ;; Entre escombros (trabajo a futuro)
    die
  ]

  ;;; Revelar links si se desea debuggear
  ;ask links [ set hidden? false ]
end

to load-inundation
  ;;; Leer una linea de los datos de inundacion
  ;;; Similar al modulo load-world, consultarlo para referencia
  foreach data [ values ->
    let the-x substring values 1 4
    let the-y substring values 5 8
    let the-color substring values 9 11
    set the-x read-from-string the-x
    set the-y read-from-string the-y
    set the-color read-from-string the-color
    set the-y ( the-y - 1 )* (-1)  ;; en este archivo, las filas (valores de y) se leen de abajo hacia arriba,
                                   ;; pero en el de inundacion, las filas se leen de arriba hacia abajo. Por eso se hace una inversion en los valores de y
    ask patch the-x the-y [set pcolor the-color]
  ]
end


to set-speed
  ;;; Asignar velocidad a los evacuadores segun el tipo de terreno en el que se encuentren.
  ;;; Las velocidades se dan en funcion de asphalted-speed, beach-speed y sus respectivas desviaciones estandar (ver Sulaeman_etal(2013)).
  ;;;
  if ( member? one-of nodes-here pavs ) [  set max-speed random-normal asphalted-speed asphalted-speed-stdev ] ;; en terrenos pavimentados, asp-sp
  if ( member? one-of nodes-here no-pavs ) [  set max-speed random-normal (asphalted-speed * 1.0) (asphalted-speed-stdev * 1.0)  ] ;; en caminos no pavimentados, asp-sp
  if ( member? one-of nodes-here senderos ) [  set max-speed random-normal beach-speed beach-speed-stdev  ] ;; en senderos, bea-sp
  if ( member? one-of nodes-here bosques ) [  set max-speed random-normal (asphalted-speed * 0.90) (asphalted-speed-stdev * 0.90)  ]  ;; en bosques, 90% de asp-sp
  if ( member? one-of nodes-here sembrados ) [  set max-speed random-normal (asphalted-speed * 0.96) (asphalted-speed-stdev * 0.96)  ] ;; en siembras, 96% de asp-sp
  if ( member? one-of nodes-here puentes ) [  set max-speed random-normal (asphalted-speed * 1.0) (asphalted-speed-stdev * 0.9)  ] ;; en puentes, asp-sp
  if ( member? one-of nodes-here playas ) [  set max-speed random-normal beach-speed beach-speed-stdev  ] ;; en playas, bea-sp

end

to move-efficiently

  ask one-of nodes-here [
    ;;; Calcular ruta optima para llegar al punto de encuentro (menor distancia pesando el riesgo de cambiar de celda)
    ;;; El punto de encuentro se ubica en la celda (en 46,-6)
    let path-to-follow (
      nw:turtles-on-weighted-path-to ( one-of nodes-on patch 46 -6 ) weight ;create list of turtles to follow
    )

    ;;; Si el agente ya llego al punto de encuentro, desaparece y aumenta el conteo de evacuadores salvados
    ;;; Si no ha llegado, se mueve en direccion a la siguiente celda de la ruta optima.
    if-else ( length path-to-follow = 1 )[;; condicion que indica si el agente llego al punto de encuentro
      ask myself[ die ]                   ;; si ya llego, desaparecer...
      set salvados salvados + 1             ;; ... y aumentar el conteo de evacuadores salvados
    ]
    [                                     ;;si el agente no ha llegado
      ask myself
        [
          face item 1 path-to-follow    ;; dirigir la vista hacia la siguiente celda de la ruta optima
          forward-carefully             ;; y moverse en esa direccion, cuidando no dar movimientos no permitidos por el modelo
      ]
    ]
  ]
end

to forward-carefully
  ;;; Moverse sin hacer movimientos no permitidos por el modelo
  ;;; si el movimiento esta prohibido, moverse en otra direccion
  if-else ( ( is-patch? (patch-ahead max-speed) ) and ( [forbidden-patch?] of (patch-ahead max-speed) ) = 0) [
    face one-of (nodes-on neighbors4) ;; Si el movimiento no esta permitido, ver hacia otra direccion que si este permitida...
    forward 0.9 ]                       ;; ... y moverse menos de una celda en esa direccion, en la cual estamos seguros de que el movimiento es permitido
  [
    forward max-speed                 ;; Si el movimiento es permitido, hacer ese movimiento.
  ]
end

to-report forbidden-patch?
  ;;; Reporta 0 si el movimiento que se intenta hacer es prohibidos por el sistema, y 1 si el movimiento es permitido.
  if ( ([pcolor] of self) = black ) [ report 0 ] ; Pasar sobre escombros (trabajo a futuro)
  if-else ( ( (is-patch? self) and ([pcolor] of self) > 81 and ([pcolor] of self) < 109 ) ) [ ;; no es permitido saltar directo al agua
    report 0
  ]
  [
    report 1
  ]
end

to move-semirandom
  ;;; Moverse de manera semi-aleatoria. El agente se movera un promedio de panic veces en una direccion aleatoria
  if-else ( (random-float 1) < panic  ) [ ;; tomar un numero aleatorio enre 0 y 1 de una distribucion normal
    face one-of (nodes-on neighbors4) ;; Si este es mayor a panic, ver hacia uno de los vecinos con un nodo asociado...
    forward-carefully                 ;; ...y caminar en esa direccion
  ]
  [                                   ;; Si el n umero aleatorio es menor a panic,
    move-efficiently                  ;; moverse en la direccion optima hacia el punto de encuentro
  ]
end

to move-followers
  ;;; Seguir a un evacuador optimo, si lo encuentra en su rango de vision; si no hay ninguno, tomar una direccion aleatoria
  if-else ( count ((evacuees in-cone visibilidad visual-field) with [color = green]) > 1 ) [ ;; si hay evacuadores optimos en en rango de vision del evacuador seguidor
    face ( one-of ((evacuees in-cone visibilidad visual-field) with [color = green]) ) ;; elegir uno y voltear hace ese agente...
    forward-carefully                                                                  ;; ...y caminar en su direccion
  ]  [
    face one-of (nodes-on neighbors4) ;; si no hay evacuadores optimos en el rango de vision, voltear hacia un nodo en su aleatorio en su vecindad...
    forward-carefully                 ;; ... y caminar en su direccion
  ]
  ;]
end

to-report numero-de-salvados
  report salvados
end
@#$#@#$#@
GRAPHICS-WINDOW
230
10
1343
344
-1
-1
13.0
1
10
1
1
1
0
0
0
1
0
84
-24
0
1
1
1
ticks
30.0

BUTTON
25
14
98
47
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
123
12
186
45
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
39
288
111
333
NIL
salvados
17
1
11

SLIDER
0
60
172
93
panic-av
panic-av
0
1
0.5
0.05
1
%
HORIZONTAL

SLIDER
0
100
172
133
panic-std
panic-std
0
1.0
0.2
0.05
1
%
HORIZONTAL

SLIDER
0
134
224
167
av-evac-start
av-evac-start
0
200
30.0
1
1
*0.53 min
HORIZONTAL

SLIDER
0
169
231
202
std-evac-start
std-evac-start
0
50
10.0
1
1
*0.53 min
HORIZONTAL

SLIDER
0
205
172
238
visibilidad
visibilidad
0
3
3.0
1
1
*100 m
HORIZONTAL

SLIDER
2
243
176
276
trained_persons
trained_persons
0.1
1
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
0
332
217
365
evacuees-population
evacuees-population
100
3200
100.0
100
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

blue
true
10
Polygon -7500403 true false 150 5 40 250 150 205 260 250

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="averages" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>numero-de-salvados</metric>
    <metric>timer</metric>
    <enumeratedValueSet variable="av-evac-start">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="panic-av">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="panic-std">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="std-evac-start">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibilidad">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="varyEvacStart" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>numero-de-salvados</metric>
    <metric>timer</metric>
    <steppedValueSet variable="av-evac-start" first="10" step="10" last="180"/>
    <enumeratedValueSet variable="panic-av">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="panic-std">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="std-evac-start">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibilidad">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="varyPanic" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>numero-de-salvados</metric>
    <metric>timer</metric>
    <enumeratedValueSet variable="av-evac-start">
      <value value="30"/>
    </enumeratedValueSet>
    <steppedValueSet variable="panic-av" first="0.25" step="0.05" last="0.75"/>
    <enumeratedValueSet variable="panic-std">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="std-evac-start">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibilidad">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="varyTrainedPersons" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>numero-de-salvados</metric>
    <metric>timer</metric>
    <enumeratedValueSet variable="av-evac-start">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="panic-av">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="panic-std">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="std-evac-start">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibilidad">
      <value value="3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="trained_persons" first="0.1" step="0.1" last="0.9"/>
  </experiment>
  <experiment name="varyVisibility" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>numero-de-salvados</metric>
    <metric>timer</metric>
    <enumeratedValueSet variable="av-evac-start">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="panic-av">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="panic-std">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="std-evac-start">
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="visibilidad" first="0.5" step="0.5" last="3"/>
    <enumeratedValueSet variable="trained_persons">
      <value value="0.3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="varyPopulation" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>numero-de-salvados</metric>
    <metric>timer</metric>
    <enumeratedValueSet variable="evacuees-population">
      <value value="100"/>
      <value value="200"/>
      <value value="400"/>
      <value value="800"/>
      <value value="1600"/>
      <value value="3200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="av-evac-start">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="panic-av">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="panic-std">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="std-evac-start">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibilidad">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trained_persons">
      <value value="0.3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="varyVisibility800" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>numero-de-salvados</metric>
    <metric>timer</metric>
    <enumeratedValueSet variable="av-evac-start">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="panic-av">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="panic-std">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="std-evac-start">
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="visibilidad" first="0.5" step="0.5" last="3"/>
    <enumeratedValueSet variable="trained_persons">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evacuees-population">
      <value value="800"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

short
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 75 120 105
Line -7500403 true 150 75 180 105
@#$#@#$#@
0
@#$#@#$#@
