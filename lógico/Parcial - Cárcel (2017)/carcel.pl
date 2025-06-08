/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% guardia(Nombre)
guardia(bennett).
guardia(mendez).
guardia(george).

% prisionero(Nombre, Crimen)
prisionero(piper, narcotrafico([metanfetaminas])).
prisionero(alex, narcotrafico([heroina])).
prisionero(alex, homicidio(george)).
prisionero(red, homicidio(rusoMafioso)).
prisionero(suzanne, robo(450000)).
prisionero(suzanne, robo(250000)).
prisionero(suzanne, robo(2500)).
prisionero(dayanara, narcotrafico([heroina, opio])).
prisionero(dayanara, narcotrafico([metanfetaminas])).

% PUNTO I

% controla(Controlador, Controlado)

controla(piper, alex).
controla(bennett, dayanara).
% controla(Guardia, Otro):- prisionero(Otro,_), not(controla(Otro, Guardia)).

/*
                    Dado el prediocado controla/2:

    Indicar, justificando, si es inversible y, en caso de no serlo, 
    dar ejemplos de las consultas que NO podrían hacerse y corregir 
    la implementación para que se pueda.


    Es inversible solamente para el prisionero, pero para el guardia no.
    Esto sucede porque el not tiene problemas de inversibilidad.

    Una consulta que no podría hacerse es: controla(Guardia,alex).

*/

controla(Guardia, Otro):- 
    prisionero(Otro,_),
    guardia(Guardia), 
    not(controla(Otro, Guardia)).

% PUNTO II

seControlanMutuamente(Persona1,Persona2):-
    controla(Persona1,Persona2),
    controla(Persona2,Persona1).

conflictoDeIntereses(Persona1,Persona2):-
    controla(Persona1,Persona3),
    controla(Persona1,Persona3),
    not(seControlanMutuamente(Persona1,Persona2)),
    Persona1 \= Persona2.

% PUNTO III

grave(homicidio(_)).

grave(narcotrafico(Drogas)):-
    length(Drogas,CantidadDeDrogas),
    CantidadDeDrogas >= 5.

grave(narcotrafico(Drogas)):-
    member(metanfetaminas,Drogas).

peligroso(Prisionero):-
    prisionero(Prisionero,_),
    forall((prisionero(Prisionero,Crimen)),(grave(Crimen))).

% Otra alternativa para el PUNTO III

cometioDelitoLeve(Prisionero):-
    prisionero(Prisionero,Crimen),
    not(grave(Crimen)).

peligrosoAlternativa(Prisionero):-
    prisionero(Prisionero,_),
    not(cometioDelitoLeve(Prisionero)).

% PUNTO IV

esRobo(robo(_)).

esMayorA100K(robo(CantidadRobada)):-
    CantidadRobada > 100000.

ladronDeGuanteBlanco(Prisionero):-
    prisionero(Prisionero,_),
    forall((prisionero(Prisionero,Crimen)),(esRobo(Crimen),esMayorA100K(Crimen))).

% Otra alternativa para PUNTO IV

monto(robo(Monto),Monto).

ladronDeGuanteBlancoAlternativa(Prisionero):-
    prisionero(Prisionero,_),
    forall((prisionero(Prisionero,Crimen)),(monto(Crimen,Monto),Monto > 100000)).

% PUNTO V

adicionales(Persona,2):-
    guardia(Persona).

adicionales(Persona,0):-
    not(guardia(Persona)).

condenaCrimen(robo(Dinero),Condena):-
    Condena is (Dinero // 10000).

condenaCrimen(homicidio(Persona),Condena):-
    adicionales(Persona,Adicionales),
    Condena is 7 + Adicionales.

condenaCrimen(narcotrafico(Drogas),Condena):-
    length(Drogas,CantidadDeDrogas),
    Condena is CantidadDeDrogas * 2.

condena(Prisionero,Condena):-
    prisionero(Prisionero,_),
    findall(Anios,(prisionero(Prisionero,Crimen),condenaCrimen(Crimen,Anios)),TotalAnios),
    sumlist(TotalAnios,Condena).

% PUNTO VI

loControla(Persona1,Persona2):-
    controla(Persona1,Persona2).

loControla(Persona1,Persona2):-
    controla(Persona1,Persona3),
    loControla(Persona3,Persona2).

persona(Persona):-
    prisionero(Persona,_).

persona(Persona):-
    guardia(Persona).

capoDiTutiLiCapi(Prisionero):-
    prisionero(Prisionero,_),
    not(controla(_,Prisionero)),
    forall((persona(Persona),Prisionero \= Persona),(loControla(Prisionero,Persona))).
