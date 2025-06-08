/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

%resultado(UnPais, GolesDeUnPais, OtroPais, GolesDeOtroPais).

resultado(paisesBajos, 3, estadosUnidos, 1). % Paises bajos 3 - 1 Estados unidos
resultado(australia, 1, argentina, 2). % Australia 1 - 2 Argentina
 
resultado(polonia, 3, francia, 1).
resultado(inglaterra, 3, senegal, 0).

pronostico(juan, gano(paisesBajos, estadosUnidos, 3, 1)).
pronostico(juan, gano(argentina, australia, 3, 0)).
pronostico(juan, empataron(inglaterra, senegal, 0)).
pronostico(gus, gano(estadosUnidos, paisesBajos, 1, 0)).
pronostico(gus, gano(japon, croacia, 2, 0)).
pronostico(lucas, gano(paisesBajos, estadosUnidos, 3, 1)).
pronostico(lucas, gano(argentina, australia, 2, 0)).
pronostico(lucas, gano(croacia, japon, 1, 0)).

% PUNTO I - A

resultadoSimetrico(Pais1,Pais2,GolesPais1,GolesPais2):-
    resultado(Pais1,GolesPais1,Pais2,GolesPais2).

resultadoSimetrico(Pais1,Pais2,GolesPais1,GolesPais2):-
    resultado(Pais2,GolesPais2,Pais1,GolesPais1).

jugaron(Pais1, Pais2, Diferencia):-
    resultadoSimetrico(Pais1,Pais2,GolesPais1,GolesPais2),
    Diferencia is (GolesPais1 - GolesPais2).

% PUNTO I - B

gano(Ganador,Perdedor):-
    jugaron(Ganador,Perdedor,Diferencia),
    Diferencia > 0.

% PUNTO II

hayResultado(gano(Ganador,Perdedor,_,_)):-
    jugaron(Ganador,Perdedor,_).

hayResultado(empate(Ganador,Perdedor,_)):-
    jugaron(Ganador,Perdedor,_).

lePegoGanadorOEmpate(gano(Ganador,Perdedor,_,_)):-
    gano(Ganador,Perdedor).

lePegoGanadorOEmpate(empate(Pais1,Pais2,_)):-
    jugaron(Pais1,Pais2,0).

lePegoResultado(gano(Ganador,Perdedor,PuntosG,PuntosP)):-
    jugaron(Ganador,Perdedor,Diferencia),
    Diferencia = PuntosG - PuntosP.

lePegoResultado(empate(Pais1,Pais2,Goles)):-
    resultadoSimetrico(Pais1,Pais2,Goles,Goles).

puntajeObtenido(Pronostico,200):-
    lePegoGanadorOEmpate(Pronostico),
    lePegoResultado(Pronostico).

puntajeObtenido(Pronostico,100):-
    lePegoGanadorOEmpate(Pronostico),
    not(lePegoResultado(Pronostico)).

puntajeObtenido(Pronostico,0):-
    not(lePegoGanadorOEmpate(Pronostico)).

puntosPronostico(Pronostico,Puntos):-
    pronostico(_,Pronostico),
    hayResultado(Pronostico),
    puntajeObtenido(Pronostico,Puntos).

% PUNTO III

invicto(Jugador):-
    pronostico(Jugador,_),
    forall((pronostico(Jugador,Pronostico),hayResultado(Pronostico)),(puntosPronostico(Pronostico,Puntos),Puntos >= 100)).

% PUNTO IV

puntaje(Jugador,Puntaje):-
    pronostico(Jugador,_),
    findall(Puntos,(pronostico(Jugador,Pronostico),puntosPronostico(Pronostico,Puntos)),PuntosJugador),
    sumlist(PuntosJugador,Puntaje).

% PUNTO V

favorito(Pais) :-
    estaEnElPronostico(Pais, _),
    forall(estaEnElPronostico(Pais, Pronostico), loDaComoGanador(Pais, Pronostico)).

favorito(Pais) :-
    resultadoSimetrico(Pais, _, _, _),
    forall(jugaron(Pais, _, DiferenciaGol), DiferenciaGol >= 3).

loDaComoGanador(Pais, gano(Pais, _, _, _)).

estaEnElPronostico(Pais, gano(Pais, OtroPais, Goles1, Goles2)) :-
    pronostico(_, gano(Pais, OtroPais, Goles1, Goles2)).
estaEnElPronostico(Pais, gano(OtroPais, Pais, Goles1, Goles2)) :-
    pronostico(_, gano(OtroPais, Pais, Goles1, Goles2)).
estaEnElPronostico(Pais, empataron(Pais, OtroPais, Goles)) :-
    pronostico(_, empataron(Pais, OtroPais, Goles)).
estaEnElPronostico(Pais, empataron(OtroPais, Pais, Goles)) :-
    pronostico(_, empataron(OtroPais, Pais, Goles)).