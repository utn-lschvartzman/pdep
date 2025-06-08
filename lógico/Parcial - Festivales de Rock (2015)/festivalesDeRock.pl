/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

/*
                        ACLARACIÓN IMPORTANTE
    
    En el repo ya hay una práctica integradora con el mismo nombre,
    sin embargo, esta versión es muchísimo más compleja y creo que
    si te salió la anterior, vale la pena totalmente intentar esta.

*/

anioActual(2015).

% festival/4: festival(Nombre, Lugar, Bandas, Precio Base). 
% - Lugar es un functor: lugar(Lugar, Capacidad).

festival(lulapaluza, lugar(hipodromo,40000), [miranda, paulMasCarne, muse], 500).
festival(mostrosDelRock, lugar(granRex, 10000), [kiss, judasPriest, blackSabbath], 1000).
festival(personalFest, lugar(geba, 5000), [tanBionica, miranda, muse, pharrellWilliams], 300).
festival(cosquinRock, lugar(aerodromo, 2500), [erucaSativa, laRenga], 400).


% banda/4: banda(Nombre, Año, Nacionalidad, Popularidad).

banda(paulMasCarne,1960, uk, 70).
banda(muse,1994, uk, 45).
banda(kiss,1973, us, 63).
banda(erucaSativa,2007, ar, 60).
banda(judasPriest,1969, uk, 91).
banda(tanBionica,2012, ar, 71).
banda(miranda,2001, ar, 38).
banda(laRenga,1988, ar, 70).
banda(blackSabbath,1968, uk, 96).
banda(pharrellWilliams,2014, us, 85).

% entradasVendidas/3: entradasVendidas(Festival, Tipo de Entrada, Cantidad Vendida).

% Tipo de Entrada es un functor: campo, plateaNumerada(numero de fila), plateaGeneral(zona).

entradasVendidas(lulapaluza,campo, 600).
entradasVendidas(lulapaluza,plateaGeneral(zona1), 200).
entradasVendidas(lulapaluza,plateaGeneral(zona2), 300).
entradasVendidas(mostrosDelRock,campo,20000).
entradasVendidas(mostrosDelRock,plateaNumerada(1),40).
entradasVendidas(mostrosDelRock,plateaNumerada(2),0).
% … y asi para todas las filas
entradasVendidas(mostrosDelRock,plateaNumerada(10),25).
entradasVendidas(mostrosDelRock,plateaGeneral(zona1),300).
entradasVendidas(mostrosDelRock,plateaGeneral(zona2),500).


plusZona(hipodromo, zona1, 55).
plusZona(hipodromo, zona2, 20).
plusZona(granRex, zona1, 45).
plusZona(granRex, zona2, 30).
plusZona(aerodromo, zona1, 25).

% PUNTO I

esReciente(Banda):-
    banda(Banda,Anio,_,_),
    anioActual(AnioActual),
    (AnioActual - Anio) =< 5.

esPopular(Banda):-
    banda(Banda,_,_,Popularidad),
    Popularidad > 70.

estaDeModa(Banda):-
    esReciente(Banda),
    esPopular(Banda).

% PUNTO II

toca(Banda,Festival):-
    festival(Festival,_,Bandas,_),
    member(Banda,Bandas).

tocaBandaDeModa(Banda,Festival):-
    toca(Banda,Festival),
    estaDeModa(Banda).

esCareta(Festival):-
    toca(miranda,Festival).

esCareta(Festival):-
    tocaBandaDeModa(Banda,Festival),
    tocaBandaDeModa(Otra,Festival),
    Banda \= Otra.

% PUNTO III - DIFÍCIL (Bah, en realidad MUY EXTENSO).

precioBase(Festival,PrecioBase):-
    festival(Festival,_,_,PrecioBase).

popularidadTotal(Festival,Total):-
    festival(Festival,_,_,_),
    findall(Popularidad,(toca(Banda,Festival),banda(Banda,_,_,Popularidad)),Lista),
    sumlist(Lista,Total).

tocanBandasUnder(Festival):-
    forall(toca(Banda,Festival),not(estaDeModa(Banda))).

cumpleCondicion(Precio,Festival):-
    festival(Festival,lugar(_,Capacidad),_,_),
    Precio < Capacidad.

cumpleCondicion(Precio,Festival):-
    popularidadTotal(Festival,Total),
    Precio < Total.

% precio/2: precio(Entrada, Festival, Precio)
precio(campo,Festival,Precio):-
    precioBase(Festival,Precio).

precio(plateaNumerada(Fila),Festival,Precio):-
    precioBase(Festival,PrecioBase),
    Precio is PrecioBase + (200 / Fila).

precio(plateaGeneral(Zona),Festival,Precio):-
    festival(Festival,lugar(Lugar,_),_,_),
    precioBase(Festival,PrecioBase),
    plusZona(Lugar,Zona,PlusZona),
    Precio is PrecioBase + PlusZona.

% esRazonable/2: esRazonable(Entrada (Tipo), Festival)
esRazonable(plateaGeneral(Zona),Festival):-
    festival(Festival,lugar(Lugar,_),_,_),
    plusZona(Lugar,Zona,PlusZona),
    precio(plateaGeneral(Zona),Festival,Precio),
    PlusZona < (Precio * (10 / 100)).

esRazonable(campo,Festival):-
    popularidadTotal(Festival,Total),
    precio(campo,Festival,Precio),
    Precio < Total.

esRazonable(plateaNumerada(Fila),Festival):-
    festival(Festival,_,_,_),
    tocanBandasUnder(Festival),
    precio(plateaNumerada(Fila),Festival,Precio),
    Precio =< 750.

esRazonable(plateaNumerada(Fila),Festival):-
    festival(Festival,_,_,_),
    not(tocanBandasUnder(Festival)),
    precio(plateaNumerada(Fila),Festival,Precio),
    cumpleCondicion(Precio,Festival).

% Relaciona a una entrada con un festival, si es RAZONABLE para ese festival.
entradaRazonable(Festival,Entrada):-
    entradasVendidas(Festival,Entrada,_),
    esRazonable(Entrada,Festival).

% PUNTO IV

% Declaro que nuestro país es argentina para que, en caso de querer llevarlo a otros países, también funcione (y no esté hardcodeado).
nacionalidad(ar).

esExtranjera(Banda):-
    banda(Banda,_,Pais,_),
    nacionalidad(Nacional),
    Pais \= Nacional.

tocaBandaExtranjera(Festival):-
    toca(Banda,Festival),
    esExtranjera(Banda).

nacAndPop(Festival):-
    entradaRazonable(Festival,_),
    not(tocaBandaExtranjera(Festival)).

% Otra alternativa para PUNTO IV

nacAndPopAlternativa(Festival):-
    entradaRazonable(Festival,_),
    festival(Festival,_,Bandas,_),
    forall(member(Banda,Bandas),not(esExtranjera(Banda))).

% PUNTO V

recaudacion(Festival,Recaudacion):-
    festival(Festival,_,_,_),
    findall(Venta,(entradasVendidas(Festival,Entrada,Cantidad),precio(Entrada,Festival,Precio),Venta is Precio * Cantidad),Ventas),
    sumlist(Ventas,Recaudacion).

% PUNTO VI

esMasPopular(Banda,Otra):-
    banda(Banda,_,_,Popularidad),
    banda(Otra,_,_,OtraPopularidad),
    Popularidad > OtraPopularidad.

esViejaEscuela(Banda):-
    banda(Banda,Anio,_,_),
    Anio < 1980.

esLegendaria(Banda):-
    esExtranjera(Banda),
    esViejaEscuela(Banda),
    forall((estaDeModa(Moda),Banda \= Moda),esMasPopular(Banda,Moda)).

popularidadCreciente([]).

popularidadCreciente([Ultima]):-
    esLegendaria(Ultima).

popularidadCreciente([Primera, Segunda | Bandas]):-
    not(esMasPopular(Primera,Segunda)),
    popularidadCreciente([Segunda | Bandas]).

estaBienPlaneado(Festival):-
    festival(Festival,_,Bandas,_),
    popularidadCreciente(Bandas).