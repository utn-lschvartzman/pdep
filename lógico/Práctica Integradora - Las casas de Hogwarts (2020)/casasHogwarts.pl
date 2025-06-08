/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% PARTE I: Sombrero seleccionador

mago(Mago):-
    sangre(Mago,_).

sangre(harry,mestiza).
sangre(draco,pura).
sangre(hermione,impura).

caracteristica(harry,corajudo).
caracteristica(harry,amistoso).
caracteristica(harry,orgulloso).
caracteristica(harry,inteligente).
caracteristica(draco,inteligente).
caracteristica(draco,orgulloso).
caracteristica(hermione,inteligente).
caracteristica(hermione,orgullosa).
caracteristica(hermione,responsable).

odia(harry,slytherin).
odia(draco,hufflepuff).

casa(gryffindor).
casa(slytherin).
casa(ravenclaw).
casa(hufflepuff).

importante(gryffindor,corajudo).
importante(slytherin,orgulloso).
importante(slytherin,inteligente).
importante(ravenclaw,inteligente).
importante(ravenclaw,responsable).
importante(hufflepuff,amistoso).

% PUNTO I

% permiteEntrar/2: permiteEntrar(Casa,Mago)

permiteEntrar(Casa,Mago):-
    casa(Casa),
    mago(Mago),
    Casa \= slytherin.

permiteEntrar(slytherin,Mago):-
    sangre(Mago,Sangre),
    Sangre \= impura.

% PUNTO II

tieneCaracterApropiado(Mago,Casa):-
    mago(Mago),
    casa(Casa),
    forall((importante(Casa,Caracteristica)),(caracteristica(Mago,Caracteristica))).

% PUNTO III

puedeQuedarSeleccionado(hermione,gryffindor).

puedeQuedarSeleccionado(Mago,Casa):-
    tieneCaracterApropiado(Mago,Casa),
    permiteEntrar(Casa,Mago),
    not(odia(Mago,Casa)).

% PUNTO IV

sonAmistosos(Cadena):-
    forall(member(Cadena,Mago),caracteristica(Mago,amistoso)).

cadenaDeAmistades(Cadena):-
    sonAmistosos(Cadena),
    cadenaDeCasas(Cadena).

cadenaDeCasas([]).
cadenaDeCasas([_]).
cadenaDeCasas([Mago1, Mago2 | Cadena]):-
    puedeQuedarSeleccionado(Mago2,Casa),
    puedeQuedarSeleccionado(Mago1,Casa),
    cadenaDeCasas([Mago2 | Cadena]).

% Otra alternativa para PUNTO IV

cadenaDeCasasAlternativa(Magos):-
    forall(consecutivos(Mago1, Mago2, Magos), puedenQuedarEnLaMismaCasa(Mago1, Mago2, _)).

consecutivos(Anterior, Siguiente, Lista):-
  nth1(IndiceAnterior, Lista, Anterior),
  IndiceSiguiente is IndiceAnterior + 1,
  nth1(IndiceSiguiente, Lista, Siguiente).

puedenQuedarEnLaMismaCasa(Mago1, Mago2, Casa):-
  puedeQuedarSeleccionado(Mago1, Casa),
  puedeQuedarSeleccionado(Mago2, Casa),
  Mago1 \= Mago2.

% PARTE II: La copa de las casas

accion(harry,andarFueraDeCama).
accion(hermione,ir(tercerPiso)).
accion(hermione,ir(seccionRestringida)).
accion(harry,ir(bosque)).
accion(harry,ir(tercerPiso)).
accion(draco,ir(mazmorras)).
accion(ron,ganarAjedrez).
accion(hermione,salvarAmigos).
accion(harry,ganarAVoldemort).

% Agregado PUNTO IV -----------------------------------------------------

accion(hermione,responder("¿Dónde se encuentra un Bezoar?",20,snape)).
accion(hermione,responder("¿Cómo hacer levitar una pluma?",25,flitwick)).

% -----------------------------------------------------------------------

prohibido(bosque,-50).
prohibido(seccionRestringida,-10).
prohibido(tercerPiso,-75).

puntos(andarFueraDeCama,-50).

puntos(ir(Lugar),Puntos):-
    prohibido(Lugar,Puntos).

puntos(ir(Lugar),0):-
    not(prohibido(Lugar,_)).

% Agregado PUNTO IV ----------------------------------

puntos(responder(_,Dificultad,snape),Puntos):-
    Puntos is (Dificultad // 2).

puntos(responder(_,Dificultad,Maestro),Dificultad):-
    Maestro \= snape.

% ----------------------------------------------------

puntos(ganarAjedrez,50).
puntos(salvarAmigos,50).
puntos(ganarAVoldemort,60).

% esDe/2: esDe(Mago,Casa)

esDe(hermione, gryffindor).
esDe(ron, gryffindor).
esDe(harry, gryffindor).
esDe(draco, slytherin).
esDe(luna, ravenclaw).

% PUNTO I - A

malaAccion(Accion):-
    puntos(Accion,Puntos),
    Puntos < 0.

hizoMalaAccion(Mago):-
    accion(Mago,Accion),
    malaAccion(Accion).

buenAlumno(Mago):-
    accion(Mago,_),
    not(hizoMalaAccion(Mago)).

% PUNTO I - B

esRecurrente(Accion):-
    accion(Mago1,Accion),
    accion(Mago2,Accion),
    Mago1 \= Mago2.

% PUNTO II

puntajeMago(Mago,Total):-
    mago(Mago),
    findall(Puntos,(accion(Mago,Accion),puntos(Accion,Puntos)),Puntaje),
    sumlist(Puntaje,Total).

puntajeCasa(Casa,Total):-
    casa(Casa),
    findall(Puntos,(esDe(Mago,Casa),puntajeMago(Mago,Puntos)),Puntaje),
    sumlist(Puntaje,Total).

% PUNTO III

casaGanadora(Casa):-
    puntajeCasa(Casa,Puntaje),
    forall((casa(OtraCasa),puntajeCasa(OtraCasa,PuntajeOtraCasa),Casa \= OtraCasa),Puntaje > PuntajeOtraCasa).

% PUNTO IV

% Ver más arriba.
