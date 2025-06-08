/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% festival(NombreDelFestival, Bandas, Lugar).
% Relaciona el nombre de un festival con la lista de los nombres de bandas que tocan en él y el lugar dónde se realiza.
festival(lollapalooza, [gunsAndRoses, theStrokes, ..., littoNebbia], hipodromoSanIsidro).

festival(prolog,[forall,findall,sumlist],utnCampus).
festival(prolog,[forall,findall,sumlist],utnHaedo).
festival(prolog,[findall,sumlist,forall],utnMedrano).

% lugar(nombre, capacidad, precioBase).
% Relaciona un lugar con su capacidad y el precio base que se cobran las entradas ahí.
lugar(hipodromoSanIsidro, 85000, 3000).
lugar(utnCampus,5000,100).

% banda(nombre, nacionalidad, popularidad).
% Relaciona una banda con su nacionalidad y su popularidad.
banda(gunsAndRoses, eeuu, 69420).
banda(forall,argentina,1).
banda(findall,argentina,2).
banda(sumlist,argentina,3).

% entradaVendida(NombreDelFestival, TipoDeEntrada).
% Indica la venta de una entrada de cierto tipo para el festival 
% indicado.
% Los tipos de entrada pueden ser alguno de los siguientes: 
%     - campo
%     - plateaNumerada(Fila)
%     - plateaGeneral(Zona).
entradaVendida(lollapalooza, campo).
entradaVendida(lollapalooza, plateaNumerada(1)).
entradaVendida(lollapalooza, plateaGeneral(zona2)).

% plusZona(Lugar, Zona, Recargo)
% Relacion una zona de un lugar con el recargo que le aplica al precio de las plateas generales.
plusZona(hipodromoSanIsidro, zona1, 1500).

% PUNTO I

itinerante(Festival):-
    festival(Festival,Bandas,Lugar),
    festival(Festival,Bandas,OtroLugar),
    Lugar \= OtroLugar.

% PUNTO II

careta(personalFest).

careta(Festival):-
    festival(Festival,_,_),
    not(entradaVendida(Festival,campo)).

% PUNTO III

nacAndPop(Festival):-
    festival(Festival,Bandas,_),
    not(careta(Festival)),
    forall(member(Bandas,Banda),(banda(Banda,argentina,Popularidad),Popularidad > 1000)).

% PUNTO IV

cantidadEntradasVendidas(Festival,Cantidad):-
    findall(_,entradaVendida(Festival,_),Entradas),
    length(Entradas, Cantidad).

sobrevendido(Festival):-
    festival(Festival,_,Lugar),
    lugar(Lugar,Capacidad,_),
    cantidadEntradasVendidas(Festival,Cantidad),
    Cantidad > Capacidad.

% PUNTO V

precioBase(Lugar,PrecioBase):-
    lugar(Lugar,_,PrecioBase).

precio(campo,Lugar,Precio):-
    precioBase(Lugar,Precio).

precio(plateaGeneral(Zona),Lugar,Precio):-
    precioBase(Lugar,PrecioBase),
    plusZona(Lugar,Zona,PlusZona),
    Precio is PrecioBase + PlusZona.

precio(plateaNumerada(Numero),Lugar,Precio):-
    precioBase(Lugar,PrecioBase),
    Numero > 10,
    Precio is PrecioBase * 3.

precio(plateaNumerada(Numero),Lugar,Precio):-
    precioBase(Lugar,PrecioBase),
    Numero =< 10,
    Precio is PrecioBase * 6.

recaudacionTotal(Festival,Recaudacion):-
    festival(Festival,_,Lugar),
    findall(Precio,(entradaVendida(Festival,Entrada),precio(Entrada,Lugar,Precio)),Precios),
    sumlist(Precios,Recaudacion).

% PUNTO VI

tocaronJuntas(Banda1,Banda2):-
    festival(_,Bandas,_),
    (member(Banda1,Bandas),member(Banda2,Bandas)),
    Banda1 \= Banda2.

masPopular(Banda1,Banda2):-
    banda(Banda1,_,Popularidad1),
    banda(Banda2,_,Popularidad2),
    Popularidad1 > Popularidad2.

delMismoPalo(Banda1,Banda2):-
    tocaronJuntas(Banda1,Banda2).

delMismoPalo(Banda1,Banda2):-
    tocaronJuntas(Banda1,Banda3),
    masPopular(Banda3,Banda2),
    delMismoPalo(Banda2,Banda3).
    