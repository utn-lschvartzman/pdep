/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% PARTE I: Vocaloids

% canta/2: canta(Vocaloid,Cancion) / Canción es un functor cancion(Nombre,Duración)
% Este predicado relaciona al vocaloid con la canción que canta

canta(megurineLuka,cancion(nigthFever,4)).
canta(megurineLuka,cancion(foreverYoung,5)).
canta(hatsuneMiku,cancion(tellYourWorld,4)).
canta(gumi,cancion(foreverYoung,4)).
canta(gumi,cancion(tellYourWorld,5)).
canta(seeU,cancion(novemberRain,6)).
canta(seeU,cancion(nigthFever,5)).

% Kaito no canta ninguna canción, entonces no se agrega a la base de conocimientos (principio de universo cerrado)

% PUNTO I

duracionTotalCanciones(Vocaloid,Total):-
    findall(Duracion,canta(Vocaloid,cancion(_,Duracion)),Duraciones),
    sumlist(Duraciones,Total).

esNovedoso(Vocaloid):-
    canta(Vocaloid,Cancion),
    canta(Vocaloid,OtraCancion),
    Cancion \= OtraCancion,
    duracionTotalCanciones(Vocaloid,Total),
    Total < 15.

% PUNTO II

cantaCancionesLargas(Vocaloid):-
    canta(Vocaloid,cancion(_,Duracion)),
    Duracion >= 5.

esAcelerado(Vocaloid):-
    canta(Vocaloid,_),
    not(cantaCancionesLargas(Vocaloid)).

% PARTE II: Conciertos

% PUNTO I

concierto(mikuExpo,estadosUnidos,2000).
concierto(magicalMirai,japon,3000).
concierto(vocalektVisions,estadosUnidos,1000).
concierto(mikuFest,argentina,100).

% PUNTO V - Agregado
concierto(prolog,argentina,10000).

tipo(mikuExpo,gigante(2,6)).
tipo(magicalMirai,gigante(3,10)).
tipo(vocalektVisions,mediano(9)).
tipo(mikuFest,pequenio(4)).

% PUNTO V - Agregado - enorme(Cantidad mínima de canciones, Duración mínima de c/canción, Acompañantes famosos mínimos)
tipo(prolog,enorme(9,9,3)).

% PUNTO II

puedeParticipar(hatsuneMiku,_).

puedeParticipar(Vocaloid,Concierto):-
    tipo(Concierto,Tipo),
    canta(Vocaloid,_),
    cumpleRequisitos(Vocaloid,Tipo).

cantidadCanciones(Vocaloid,Cantidad):-
    findall(_,canta(Vocaloid,_),Canciones),
    length(Canciones,Cantidad).

cumpleRequisitos(Vocaloid,gigante(MinimoCanciones,DuracionTotalMinima)):-
    cantidadCanciones(Vocaloid,CantidadCanciones),
    duracionTotalCanciones(Vocaloid,DuracionTotal),
    (CantidadCanciones >= MinimoCanciones, DuracionTotal >= DuracionTotalMinima).

cumpleRequisitos(Vocaloid,mediano(DuracionTotalMaxima)):-
    duracionTotalCanciones(Vocaloid,DuracionTotal),
    DuracionTotal < DuracionTotalMaxima.

cumpleRequisitos(Vocaloid,pequenio(MinimoCancion)):-
    canta(Vocaloid,cancion(_,Duracion)),
    Duracion >= MinimoCancion.

% PUNTO III

famaDeConciertos(Vocaloid,FamaDeConciertos):-
    findall(Fama,(puedeParticipar(Vocaloid,Concierto),concierto(Concierto,_,Fama)),Famas),
    sumlist(Famas,FamaDeConciertos).

fama(Vocaloid,Fama):-
    canta(Vocaloid,_),
    cantidadCanciones(Vocaloid,CantidadDeCanciones),
    famaDeConciertos(Vocaloid,FamaDeConciertos),
    Fama is CantidadDeCanciones * FamaDeConciertos.

masFamoso(Vocaloid):-
    fama(Vocaloid,Fama),
    forall((fama(OtroVocaloid,SuFama),Vocaloid \= OtroVocaloid),Fama > SuFama).

% PUNTO IV

conoce(megurineLuka,hatsuneMiku).
conoce(megurineLuka,gumi).
conoce(gumi,seeU).
conoce(seeU,kaito).

seConocen(Vocaloid,OtroVocaloid):-
    conoce(Vocaloid,OtroVocaloid).

seConocen(Vocaloid,OtroVocaloid):-
    conoce(OtroVocaloid,Vocaloid).

seConocen(Vocaloid,OtroVocaloid):-
    seConocen(Vocaloid,Intermedio),
    seConocen(Intermedio,OtroVocaloid).

unicoEnParticipar(Vocaloid,Concierto):-
    canta(Vocaloid,_),
    puedeParticipar(Vocaloid,Concierto),
    forall((seConocen(Vocaloid,Conocido),Vocaloid \= Conocido),not(puedeParticipar(Conocido,Concierto))).

% Otra Alternativa sin usar FORALL/2

otroParticipa(Vocaloid,Concierto):-
    seConocen(Vocaloid,Conocido),
    (Vocaloid \= Conocido),
    puedeParticipar(Conocido,Concierto).

unicoEnParticipar(Vocaloid,Concierto):-
    canta(Vocaloid,_),
    puedeParticipar(Vocaloid,Concierto),
    not(otroParticipa(Vocaloid,Concierto)).

% PUNTO V

% Ver más arriba, pero es fácil de implementar gracias al polimorfismo de los functores.