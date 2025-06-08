/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% juego/2: juego(Nombre, Tipo)

% juego(Juego, accion).
% juego(Juego, rol(Usuarios)).
% juego(Juego, puzzle(Niveles, Dificultad)).

% Agrego dos nuevos tipos:
% juego(Juego, sandbox(Tipo de mundo)).
% juego(Juego, ritmico(Tipo de música)).

juego(metalHellsinger,accion).
juego(counterStrike,accion).
juego(minecraft,sandbox(abierto)).
juego(hifiRush,ritmico(tech)).

% precio/2: precio(Juego, Precio)
precio(metalHellsinger,5).
precio(hifiRush, 15).

% oferta/2: oferta(Juego, % Descuento)
oferta(metalHellsinger,30).
oferta(hifiRush,70).

precioFinal(Juego,Precio):-
    precio(Juego,Precio),
    not(oferta(Juego,_)).

precioFinal(Juego,Precio):-
    precio(Juego,Base),
    oferta(Juego,Descuento),
    Precio is (Base * (Descuento / 100)).

cuantoSale(Juego,Precio):-
    juego(Juego,_),
    precioFinal(Juego,Precio).

tieneBuenDescuento(Juego):-
    oferta(Juego,Descuento),
    Descuento >= 50.

esPopularSegunTipo(accion).
esPopularSegunTipo(rol(Usuarios)):-
    Usuarios > 1000000.
esPopularSegunTipo(puzzle(25,_)).
esPopularSegunTipo(puzzle(_,facil)).

esPopular(Juego):-
    juego(Juego,Tipo),
    esPopularSegunTipo(Tipo).

esPopular(minecraft).
esPopular(counterStrike).

% usuario/1: usuario(Usuario)

usuario(aguluc).

% tiene/2: tiene(Usuario, Juego)

tiene(aguluc,metalHellsinger).
tiene(aguluc,counterStrike).
tiene(aguluc,minecraft).

% planeaTener/2: planeaTener(Usuario, Juego)

quiereComprarse(aguluc,hifiRush).
quiereRegalar(aguluc,sparko,metalHellsinger).

futuraAdquisicion(Usuario,Juego):-
    quiereComprarse(Usuario,Juego).

futuraAdquisicion(Usuario,Juego):-
    quiereRegalar(Usuario,_,Juego).

adictoADescuentos(Usuario):-
    usuario(Usuario),
    forall(futuraAdquisicion(Usuario,Adquisicion),tieneBuenDescuento(Adquisicion)).

% Alternativa para adictoADescuentos/1:

adictoADescuentosAlternativa(Usuario):-
    usuario(Usuario),
    not((futuraAdquisicion(Usuario,Adquisicion),not(tieneBuenDescuento(Adquisicion)))).

tieneJuegoGenero(Usuario,Juego,Genero):-
    tiene(Usuario,Juego),
    juego(Juego,Genero).

fanatico(Usuario,Genero):-
    tieneJuegoGenero(Usuario,Juego,Genero),
    tieneJuegoGenero(Usuario,OtroJuego,Genero),
    Juego \= OtroJuego.

monotematico(Usuario):-
    tieneJuegoGenero(Usuario,Juego,Genero),
    forall((tieneJuegoGenero(Usuario,Otro,_),Juego \= Otro), tieneJuegoGenero(Usuario,Otro,Genero)).

% Alternativa para monotematico/1: 

monotematico(Usuario):-
    usuario(Usuario),
    not((tieneJuegoGenero(Usuario,Juego,Genero),tieneJuegoGenero(Usuario,Otro,OtroGenero),Juego \= Otro, Genero \= OtroGenero)).

buenosAmigos(Usuario,Otro):-
    quiereRegalar(Usuario,Otro,_),
    quiereRegalar(Otro,Usuario,_).

cuantoGastara(Usuario,Gasto):-
    usuario(Usuario),
    findall(Precio,(futuraAdquisicion(Usuario,Adquisicion),cuantoSale(Adquisicion,Precio)),Precios),
    sumlist(Precios,Gasto).