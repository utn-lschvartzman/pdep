/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% PUNTO I - A

% cree/2: cree(Persona, Personaje en el que cree).

cree(gabriel,campanita).
cree(gabriel,magoDeOz).
cree(gabriel,cavenaghi).
cree(juan,conejoDePascua).
cree(macarena,reyesMagos).
cree(macarena,magoCapria).
cree(macarena,campanita).

% Diego no cree en nadie, entonces no se agrega a la base de conocimiento (principio de universo cerrado)

suenio(gabriel,ganarLoteria([5,9])).
suenio(gabriel,futbolista(arsenal)).
suenio(juan,cantante(_,100000)).
suenio(macarena,cantante("Eruca Sativa",10000)).

% PUNTO I - B

/*
    Entran en juego conceptos como:
        - Polimorfismo: los sueños son functores, de forma que pueden tener diferentes formas y "entrar" en el predicado suenio/2
        - Universo cerrado: por ejemplo, con Diego.

*/

% PUNTO II

esEquipoChico(arsenal).
esEquipoChico(aldosivi).

dificultad(cantante(_,Ventas),6):-
    Ventas > 500000.

dificultad(cantante(_,Ventas),4):-
    Ventas =< 500000.

dificultad(ganarLoteria(Apostados),Dificultad):-
    length(Apostados,Cantidad),
    Dificultad is 10 * Cantidad.

dificultad(futbolista(Equipo),3):-
    esEquipoChico(Equipo).

dificultad(futbolista(Equipo),16):-
    not(esEquipoChico(Equipo)).

dificultadPersona(Persona,Total):-
    suenio(Persona,_),
    findall(Dificultad,(suenio(Persona,Suenio),dificultad(Suenio,Dificultad)),Dificultades),
    sumlist(Dificultades,Total).

ambiciosa(Persona):-
    dificultadPersona(Persona,Total),
    Total > 20.

% PUNTO III

puro(futbolista(_)).
puro(cantante(_,Ventas)):-
    Ventas < 200000.

sueniosPuros(Persona):-
    forall((suenio(Persona,Suenio)),(puro(Suenio))).

% Alternativa para PUNTO III -------

tieneSuenioImpuro(Persona):-
    suenio(Persona,Suenio),
    not(puro(Suenio)).

sueniosPurosAlternativa(Persona):-
    not(tieneSuenioImpuro(Persona)).

% ----------------------------------

cumpleCondicion(Persona,campanita):-
    suenio(Persona,Suenio),
    dificultad(Suenio,Dificultad),
    Dificultad < 5.

cumpleCondicion(Persona,Personaje):-
    Personaje \= campanita,
    sueniosPuros(Persona),
    not(ambiciosa(Persona)).

tienenQuimica(Personaje,Persona):-
    cree(Persona,Personaje),
    cumpleCondicion(Persona,Personaje).

% PUNTO IV

amigoDe(campanita,reyesMagos).
amigoDe(campanita,conejoDePascua).
amigoDe(conejoDePascua,cavenaghi).

% Agrego para probar los N niveles de indireccion
amigoDe(cavenaghi,walterWhite).
amigoDe(walterWhite,jessePinkman).
amigoDe(jessePinkman,bobEsponja).

estaEnfermo(campanita).
estaEnfermo(reyesMagos).
estaEnfermo(conejoDePascua).

backup(Personaje,Backup):-
    amigoDe(Personaje,Backup).

backup(Personaje,Backup):-
    amigoDe(Personaje,Intermedio),
    backup(Intermedio,Backup).

personajeDisponible(Personaje):-
    not(estaEnfermo(Personaje)).

personajeDisponible(Personaje):-
    estaEnfermo(Personaje),
    backup(Personaje,Backup),
    not(estaEnfermo(Backup)).

puedeAlegrar(Personaje,Persona):-
    suenio(Persona,_),
    tienenQuimica(Personaje,Persona),
    personajeDisponible(Personaje).
