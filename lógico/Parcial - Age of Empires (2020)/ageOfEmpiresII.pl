/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% ...jugador(Nombre, Rating, Civilizacion).
jugador(juli, 2200, jemeres).
jugador(aleP, 1600, mongoles).
jugador(feli, 500000, persas).
jugador(aleC, 1723, otomanos).
jugador(ger, 1729, ramanujanos).
jugador(juan, 1515, britones).
jugador(marti, 1342, argentinos).
jugador(lucas,100000,argentinos).
% ... y muchos más también

% ...tiene(Nombre, QueTiene).
tiene(aleP, unidad(samurai, 199)).
tiene(aleP, unidad(espadachin, 10)).
tiene(aleP, unidad(granjero, 10)).
tiene(aleP, recurso(800, 300, 100)).
tiene(aleP, edificio(casa, 40)).
tiene(aleP, edificio(castillo, 1)).
tiene(juan, unidad(carreta, 10)).
tiene(lucas, unidad(samurai, 200)).
tiene(lucas, unidad(granjero, 400)).
tiene(lucas, unidad(carreta, 100)).
tiene(lucas, edificio(castillo, 300)).

% ... y muchos más también

% militar(Tipo, costo(Madera, Alimento, Oro), Categoria).
militar(espadachin, costo(0, 60, 20), infanteria).
militar(arquero, costo(25, 0, 45), arqueria).
militar(mangudai, costo(55, 0, 65), caballeria).
militar(samurai, costo(0, 60, 30), unica).
militar(keshik, costo(0, 80, 50), unica).
militar(tarcanos, costo(0, 60, 60), unica).
militar(alabardero, costo(25, 35, 0), piquero).
% ... y muchos más tipos pertenecientes a estas categorías.

% aldeano(Tipo, produce(Madera, Alimento, Oro)).
aldeano(lenador, produce(23, 0, 0)).
aldeano(granjero, produce(0, 32, 0)).
aldeano(minero, produce(0, 0, 23)).
aldeano(cazador, produce(0, 25, 0)).
aldeano(pescador, produce(0, 23, 0)).
aldeano(alquimista, produce(0, 0, 25)).
% ... y muchos más también

% edificio(Edificio, costo(Madera, Alimento, Oro)).
edificio(casa, costo(30, 0, 0)).
edificio(granja, costo(0, 60, 0)).
edificio(herreria, costo(175, 0, 0)).
edificio(castillo, costo(650, 0, 300)).
edificio(maravillaMartinez, costo(10000, 10000, 10000)).
% ... y muchos más también

% PUNTO I

esUnAfano(Jugador,OtroJugador):-
    jugador(Jugador,Rating,_),
    jugador(OtroJugador,OtroRating,_),
    Jugador \= OtroJugador,
    Rating - OtroRating > 500.

% PUNTO II - Asumo que una unidad no se puede ganar a sí misma

ganaSegunCategoria(caballeria,infanteria).
ganaSegunCategoria(arqueria,infanteria).
ganaSegunCategoria(infanteria,piquero).
ganaSegunCategoria(piquero,caballeria).

leGana(Unidad,OtraUnidad):-
    militar(Unidad,_,Categoria),
    militar(OtraUnidad,_,OtraCategoria),
    ganaSegunCategoria(Categoria,OtraCategoria),
    Unidad \= OtraUnidad.

leGana(samurai,Unidad):-
    militar(Unidad,_,unica).

esEfectivo(Unidad,OtraUnidad):-
    leGana(Unidad,OtraUnidad).

% PUNTO III

tieneSoloMilitaresDe(Categoria,Jugador):-
    forall(tiene(Jugador,unidad(Unidad,_)),militar(Unidad,_,Categoria)).

alarico(Jugador):-
    jugador(Jugador,_,_),
    tieneSoloMilitaresDe(infanteria,Jugador).

% PUNTO IV

leonidas(Jugador):-
    jugador(Jugador,_,_),
    tieneSoloMilitaresDe(piquero,Jugador).

% PUNTO V

nomada(Jugador):-
    not(tiene(Jugador,edificio(casa,_))).

% PUNTO VI

cuantoCuesta(Edificio,Costo):-
    edificio(Edificio,Costo).

cuantoCuesta(Militar,Costo):-
    militar(Militar,Costo,_).

cuantoCuesta(Aldeano,costo(0,50,0)):-
    aldeano(Aldeano,_).

cuantoCuesta(Unidad,costo(100,0,50)):-
    esUrnaOCarreta(Unidad).

esUrnaOCarreta(urna).
esUrnaOCarreta(carreta).

% PUNTO VII

produccion(Aldeano,Produccion):-
    aldeano(Aldeano,Produccion).

produccion(Unidad,produce(0,0,32)):-
    esUrnaOCarreta(Unidad).

produccion(keshik,produce(0,0,10)).

produccion(Militar,produce(0,0,0)):-
    militar(Militar,_,_),
    Militar \= keshik.

% PUNTO VIII

recurso(madera).
recurso(alimento).
recurso(oro).

produccionDe(oro,Productor,Cantidad,Produccion):-
    produccion(Productor,produce(Madera,_,_)),
    Produccion is Madera * Cantidad.

produccionDe(oro,Productor,Cantidad,Produccion):-
    produccion(Productor,produce(_,Alimento,_)),
    Produccion is Alimento * Cantidad.

produccionDe(oro,Productor,Cantidad,Produccion):-
    produccion(Productor,produce(_,_,Oro)),
    Produccion is Oro * Cantidad.

cantidad(Jugador,Unidad,Cantidad):-
    tiene(Jugador,unidad(Unidad,Cantidad)).

cantidad(Jugador,Edificio,Cantidad):-
    tiene(Jugador,edificio(Edificio,Cantidad)).

totalQueProduce(Jugador,Recurso,Total):-
    findall(Produccion,(tiene(Jugador,Productor),cantidad(Jugador,Productor,Cantidad),produccionDe(Recurso,Productor,Cantidad,Produccion)),Producciones),
    sumlist(Producciones,Total).

produccionTotal(Jugador,Recurso,Total):-
    jugador(Jugador,_,_),
    recurso(Recurso),
    totalQueProduce(Jugador,Recurso,Total).

% PUNTO IX

cantidadUnidades(Jugador,Total):-
    jugador(Jugador,_,_),
    findall(Cantidad,tiene(Jugador,unidad(_,Cantidad)),Cantidades),
    sumlist(Cantidades,Total).

noHayAfano(Jugador,OtroJugador):-
    not(esUnAfano(Jugador,OtroJugador)),
    not(esUnAfano(OtroJugador,Jugador)).

mismaCantidadUnidades(Jugador,OtroJugador):-
    cantidadUnidades(Jugador,Cantidad),
    cantidadUnidades(OtroJugador,Cantidad).

valor(oro,Produccion,Valor):-
    Valor is Produccion * 5.

valor(madera,Produccion,Valor):-
    Valor is Produccion * 3.

valor(alimento,Produccion,Valor):-
    Valor is Produccion * 2.

valorTotal(Jugador,Total):-
    findall(Valor,(recurso(Recurso),produccionTotal(Jugador,Recurso,Produccion),valor(Recurso,Produccion,Valor)),Valores),
    sumlist(Valores,Total).

diferenciaProduccion(Jugador,OtroJugador,Diferencia):-
    valorTotal(Jugador,Total),
    valorTotal(OtroJugador,OtroTotal),
    Diferencia is abs(Total - OtroTotal).

estaPeleado(Jugador,OtroJugador):-
    Jugador \= OtroJugador,
    noHayAfano(Jugador,OtroJugador),
    mismaCantidadUnidades(Jugador,OtroJugador),
    diferenciaProduccion(Jugador,OtroJugador,Diferencia),
    Diferencia < 100.

% PUNTO X

recurso(madera,Jugador,Madera):-
    tiene(Jugador,recurso(Madera,_,_)).

recurso(alimento,Jugador,Alimento):-
    tiene(Jugador,recurso(_,Alimento,_)).

recurso(oro,Jugador,Oro):-
    tiene(Jugador,recurso(_,_,Oro)).

satisface(herreria).
satisface(establo).
satisface(galeriaDeTiro).

cantidadRecurso(Recurso,Jugador,Total):-
    findall(Cantidad,recurso(Recurso,Jugador,Cantidad),Cantidades),
    sumlist(Cantidades,Total).

puedeAvanzar(_,media).

puedeAvanzar(Jugador,feudal):-
    tiene(Jugador,edificio(casa,_)),
    cantidadRecurso(alimento,Jugador,Alimento),
    Alimento > 500.

puedeAvanzar(Jugador,castillos):-
    tiene(Jugador,edificio(Edificio,_)),
    satisface(Edificio),
    cantidadRecurso(alimento,Jugador,Alimento),
    cantidadRecurso(oro,Jugador,Oro),
    (Oro > 200, Alimento > 800).

avanzaA(Jugador,imperial):-
    (tiene(Jugador,edificio(universidad,_)),tiene(Jugador,edificio(castillo,_))),
    cantidadRecurso(alimento,Jugador,Alimento),
    cantidadRecurso(oro,Jugador,Oro),
    (Oro > 800, Alimento > 1000).
