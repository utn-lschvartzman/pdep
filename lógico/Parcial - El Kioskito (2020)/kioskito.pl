/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% Base de conocimiento

atiende(dodain,horario(lunes,9,15)).
atiende(dodain,horario(miercoles,9,15)).
atiende(lucas,horario(martes,10,20)).
atiende(juanC,horario(sabado,18,22)).
atiende(juanC,horario(domingo,18,22)).
atiende(juanFdS,horario(jueves,10,20)).
atiende(juanFdS,horario(viernes,12,20)).
atiende(leoC,horario(lunes,14,18)).
atiende(leoC,horario(miercoles,14,18)).
atiende(martu,horario(miercoles,23,24)).

% Punto 1: Calentando motores

% Vale atiende los mismos días y horarios que dodain y juanC.

atiende(vale,Horario) :-
    atiende(juanC,Horario).

atiende(vale,Horario) :-
    atiende(dodain,Horario).

% Punto 2: Quien atiende el kisko

atiendeEnHorario(Persona,atencion(Dia,Hora)) :-
    atiende(Persona,horario(Dia,Apertura,Cierre)),
    between(Apertura,Cierre,Hora).
 
% Punto 3: Forever alone

estaForeverAlone(Persona, atencion(Dia,Hora)):-
    atiendeEnHorario(Persona,atencion(Dia,Hora)),
    not((atiendeEnHorario(OtraPersona,atencion(Dia,Hora)),Persona\=OtraPersona)).

% Punto 4: Posibilidades de atención

atiendeEnDia(Dia,Persona):-
    atiende(Persona,horario(Dia,_,_)).

posibilidadesAtencion(Dia,Personas):-
    findall(Persona, atiendeEnDia(Dia,Persona), PersonasPosibles),
    list_to_set(PersonasPosibles,Per),
    combinar(Per,Personas).

combinar([], []).

combinar([Cabeza|Cola], [Cabeza|OtraCola]):-
    combinar(Cola, OtraCola).

combinar([_|Cola], Lista):-
    combinar(Cola, Lista).

% Punto 5: Ventas / Suertudas

venta(dodain,fecha(lunes,10,agosto),[golosinas(1200), cigarrillos([jockey]),golosina(50)]).
venta(dodain, fecha(miercoles, 12, agosto), [bebida(alcoholica, 8), bebida(noAlcoholica, 1),golosinas(50)]).
venta(martu,fecha(miercoles,12,agosto),[golosinas(1000),cigarrillos([chesterfield,colorado,parisiennes])]).
venta(lucas,fecha(martes,11,agosto),[golosinas(600)]).
venta(lucas,fecha(martes,18,agosto),[bebida(noAlcoholica,2),cigarrillos([derby])]).

esSuertuda(Persona):-
    venta(Persona,_,_),
    forall(venta(Persona,_,[Venta|_]), esImportante(Venta)).

esImportante(golosinas(Precio)):-
    Precio > 100.

esImportante(cigarrillos(Marcas)):-
    length(Marcas,CantidadMarcas),
    CantidadMarcas > 2.

esImportante(bebida(alcoholica, _)).

esImportante(bebida(_,Cantidad)):-
    Cantidad > 5.

