/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% PARTE I: Piratas y Tripulaciones

% tripulante/2: tripulante(Pirata,Tripulación)

% Tripulación: Sombrero de Paja

tripulante(luffy, sombreroDePaja).
tripulante(zoro, sombreroDePaja).
tripulante(nami, sombreroDePaja).
tripulante(ussop, sombreroDePaja).
tripulante(sanji, sombreroDePaja).
tripulante(chopper, sombreroDePaja).

% Tripulación: Heart

tripulante(law, heart).
tripulante(bepo, heart).

% Tripulación: Piratas de Arlong

tripulante(arlong, piratasDeArlong).
tripulante(hatchan, piratasDeArlong).

% impactoEnRecompensa/3: impactoEnRecompensa(Pirata,Evento,Monto)

impactoEnRecompensa(luffy,arlongPark, 30000000).
impactoEnRecompensa(luffy,baroqueWorks, 70000000).
impactoEnRecompensa(luffy,eniesLobby, 200000000).
impactoEnRecompensa(luffy,marineford, 100000000).
impactoEnRecompensa(luffy,dressrosa, 100000000).
impactoEnRecompensa(zoro, baroqueWorks, 60000000).
impactoEnRecompensa(zoro, eniesLobby, 60000000).
impactoEnRecompensa(zoro, dressrosa, 200000000).
impactoEnRecompensa(nami, eniesLobby, 16000000).
impactoEnRecompensa(nami, dressrosa, 50000000).
impactoEnRecompensa(ussop, eniesLobby, 30000000).
impactoEnRecompensa(ussop, dressrosa, 170000000).
impactoEnRecompensa(sanji, eniesLobby, 77000000).
impactoEnRecompensa(sanji, dressrosa, 100000000).
impactoEnRecompensa(chopper, eniesLobby, 50).
impactoEnRecompensa(chopper, dressrosa, 100).
impactoEnRecompensa(law, sabaody, 200000000).
impactoEnRecompensa(law, descorazonamientoMasivo,240000000).
impactoEnRecompensa(law, dressrosa, 60000000).
impactoEnRecompensa(bepo,sabaody,500).
impactoEnRecompensa(arlong, llegadaAEastBlue,20000000).
impactoEnRecompensa(hatchan, llegadaAEastBlue, 3000).

% PUNTO I

participo(Tripulacion,Evento):-
    tripulante(Tripulante,Tripulacion),
    impactoEnRecompensa(Tripulante,Evento,_).

seRelacionan(Tripulacion1,Tripulacion2,Evento):-
    participo(Tripulacion1,Evento),
    participo(Tripulacion2,Evento),
    Tripulacion1 \= Tripulacion2.

% PUNTO II

destacado(Pirata,Evento):-
    impactoEnRecompensa(Pirata,Evento,Recompensa),
    forall((impactoEnRecompensa(OtroPirata,Evento,OtraRecompensa),Pirata \= OtroPirata),(Recompensa > OtraRecompensa)).

% PUNTO III

pasoDesapercibido(Pirata,Evento):-
    tripulante(Pirata,Tripulacion),
    participo(Tripulacion,Evento),
    not(impactoEnRecompensa(Pirata,Evento,_)).

% PUNTO IV

recompensaPirata(Pirata,Total):-
    tripulante(Pirata,_),
    findall(Recompensa,(impactoEnRecompensa(Pirata,_,Recompensa)),Recompensas),
    sumlist(Recompensas,Total).

recompensaTripulacion(Tripulacion,Total):-
    tripulante(_,Tripulacion),
    findall(Recompensa,(tripulante(Tripulante,Tripulacion),recompensaPirata(Tripulante,Recompensa)),Recompensas),
    sumlist(Recompensas,Total).

% PUNTO V

esPeligroso(Pirata):-
    recompensaPirata(Pirata,Recompensa),
    Recompensa > 100000000.

% --- Agregado del PUNTO VI ---

esPeligroso(Pirata):-
    comioFruta(Pirata,Fruta),
    frutaPeligrosa(Fruta).

% -----------------------------

temible(Tripulacion):-
    recompensaTripulacion(Tripulacion,Recompensa),
    Recompensa > 500000000.

temible(Tripulacion):-
    tripulante(_,Tripulacion),
    forall((tripulante(Tripulante,Tripulacion)),(esPeligroso(Tripulante))).

% PARTE II: Frutas del diablo

% comioFruta/2: comioFruta(Pirata,Fruta)

frutaPeligrosa(paramecia(opeope)).

frutaPeligrosa(zoan(_,Especie)):-
    feroz(Especie).

frutaPeligrosa(logia(_,_)).

feroz(lobo).
feroz(leopardo).
feroz(anaconda).

comioFruta(luffy,paramecia(gomugomu)).
comioFruta(buggy,paramecia(barabara)).
comioFruta(law,paramecia(opeope)).
comioFruta(chopper,zoan(hitohito,humano)).
comioFruta(lucci,zoan(nekoneko,leopardo)).
comioFruta(smoker,logia(mokumoku,humo)).

% Nami, Zoro, Ussop, Sanji, Bepo, Arlong y Hatchan no comieron frutas del diablo, por ende
% no son agregados a la base de conocimientos (principio de universo cerrado).

% PUNTO VI - A

% Ver más arriba, lo agregue para que no fueran cláusulas discontiguas.

% PUNTO VI - B

% comioFruta(Pirata,Fruta) - Fruta es un functor para poder admitir el POLIMORFISMO.

% PUNTO VII

puedeNadar(Tripulante):-
    not(comioFruta(Tripulante,_)).

piratasDeAsfalto(Tripulacion):-
    tripulante(_,Tripulacion),
    forall(tripulante(Tripulante,Tripulacion),not(puedeNadar(Tripulante))).