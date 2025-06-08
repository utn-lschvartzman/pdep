/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/
% PUNTO I

% comida/2: comida(Comida, Precio)

comida(hamburguesa,2000).
comida(panchitoConPapas,1500).
comida(lomitos,2500).
comida(caramelos,0).

% atraccion/2: atraccion(Atraccion, Tipo)

atraccion(autitosChocadores,tranquila).
atraccion(casaEmbrujada,tranquila).
atraccion(laberinto,tranquila).
atraccion(tobogan,tranquila).
atraccion(calesita,tranquila).
atraccion(barcoPirata,intensa(14)).
atraccion(tazasChinas,intensa(6)).
atraccion(simulador3D,intensa(2)).
atraccion(abismoMortalRecargada,montanaRusa(3,134)).
atraccion(paseoBosque,montanaRusa(0,45)).
atraccion(torpedoSalpicon,acuatica([septiembre,octubre,noviembre,diciembre,enero,febrero,marzo])).
atraccion(eQHTUMR,acuatica([septiembre,octubre,noviembre,diciembre,enero,febrero,marzo])).

% puedeIr/2: puedeIr(Persona,Atraccion)

exclusiva(tobogan).
exclusiva(calesita).

puedeIr(_,autitosChocadores).
puedeIr(_,casaEmbrujada).
puedeIr(_,laberinto).

puedeIr(Persona,tobogan):-
    esChico(Persona).

puedeIr(Persona,calesita):-
    esChico(Persona).

puedeIr(Persona,Atraccion):-
    atraccion(Atraccion,tranquila),
    exclusiva(Atraccion),
    esAdulto(Persona),
    grupo(Persona,Grupo),
    hayUnChico(Grupo).

hayUnChico(Grupo):-
    grupo(Chico,Grupo),
    esChico(Chico).

% persona/3: persona(Nombre, Dinero, Edad)

persona(eusebio,3000,80).

persona(carmela,0,Edad):-
    persona(eusebio,_,Edad).

% Dos personas que hayan venido solas:

persona(lucas,5000,20).
persona(sofia,10000,19).

% grupo/2: grupo(Persona,Grupo)

grupo(eusebio,viejitos).
grupo(carmela,viejitos).

% grupo(hijaUno,lopez).
% grupo(hijaDos,lopez).
% grupo (_,promocion23).

% hambre/2: hambre(Persona, Hambre)

hambre(eusebio,50).
hambre(carmela,0).

% aburrimiento/2: aburrimiento(Persona, Aburrimiento)

aburrimiento(eusebio,0).
aburrimiento(carmela,25).

% PUNTO II

estadoBienestar(Persona,felicidadPlena):-
    not(vieneSola(Persona)), % Una persona que viene sola no puede sentir felicidad plena.
    sinNecesidades(Persona).

estadoBienestar(Persona,podriaEstarMejor):-
    vieneSola(Persona),
    sinNecesidades(Persona).

estadoBienestar(Persona,podriaEstarMejor):-
    sumaSentimental(Persona,Total),
    between(1,50,Total).

estadoBienestar(Persona,necesitaEntretenerse):-
    sumaSentimental(Persona,Total),
    between(51,99,Total).

estadoBienestar(Persona,quiereIrse):-
    sumaSentimental(Persona,Total),
    Total >= 100.

sumaSentimental(Persona,Total):-
    hambre(Persona,Hambre),
    aburrimiento(Persona,Aburrimiento),
    Total is Hambre + Aburrimiento.

sinNecesidades(Persona):-
    hambre(Persona,0),
    aburrimiento(Persona,0).

vieneSola(Persona):-
    not(grupo(Persona,_)).

% PUNTO III

puedePagar(Persona,Comida):-
    comida(Comida,Precio),
    persona(Persona,Dinero,_),
    Dinero >= Precio.

quitaHambre(hamburguesa,Persona):-
    hambre(Persona,Hambre),
    Hambre < 50.

quitaHambre(panchitoConPapas,Persona):-
    esChico(Persona).

quitaHambre(lomitos,_).

quitaHambre(caramelos,Persona):-
    forall((comida(Comida,_),Comida \= caramelos),not(puedePagar(Persona,Comida))).

esChico(Persona):-
    persona(Persona,_,Edad),
    Edad < 13.

esAdulto(Persona):-
    persona(Persona,_,_),
    not(esChico(Persona)).

satisface(Comida,Grupo):-
    grupo(_,Grupo),
    comida(Comida,_),
    forall((grupo(Integrante,Grupo)),(puedePagar(Integrante,Comida),quitaHambre(Comida,Integrante))).

% PUNTO IV

esPeligrosa(MontanaRusa,Persona):-
    esAdulto(Persona),
    not(estadoBienestar(Persona,necesitaEntretenerse)),
    atraccion(MontanaRusa,montanaRusa(Giros,_)),
    forall((atraccion(OtraMontana,montanaRusa(OtrosGiros,_)),MontanaRusa \= OtraMontana),Giros > OtrosGiros).

esPeligrosa(MontanaRusa,Persona):-
    esChico(Persona),
    atraccion(MontanaRusa,montanaRusa(_,Segundos)),
    Segundos > 60.

atraccionLluvia(_,Atraccion):-
    atraccion(Atraccion,intensa(Coeficiente)),
    Coeficiente > 10.

atraccionLluvia(Persona,Atraccion):-
    atraccion(Atraccion,montanaRusa(_,_)),
    esPeligrosa(Atraccion,Persona).

atraccionLluvia(_,tobogan).

lluviaHamburguesas(Persona):-
    puedePagar(Persona,hamburguesa),
    puedeIr(Persona,Atraccion), % Supongo
    atraccionLluvia(Persona,Atraccion).

% PUNTO V

esOpcion(Persona,_,Opcion):-
    puedePagar(Persona,Opcion).

esOpcion(Persona,_,Opcion):-
    puedeIr(Persona,Opcion).

esOpcion(_,_,Opcion):-
    atraccion(Opcion,intensa(_)).

esOpcion(Persona,_,Opcion):-
    not(esPeligrosa(Opcion,Persona)).

esOpcion(_,Mes,Opcion):-
    atraccion(Opcion,acuatica(Meses)),
    member(Mes,Meses).

opcionesEntretenimiento(Mes,Persona,Opciones):-
    persona(Persona,_,_),
    findall(Opcion,esOpcion(Persona,Mes,Opcion),Todas),
    list_to_set(Todas,Opciones).