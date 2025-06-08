/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

herramientasRequeridas(limpiarTecho, [escoba, pala]).
herramientasRequeridas(cortarPasto, [bordedadora]).
herramientasRequeridas(limpiarBanio, [sopapa, trapeador]).
herramientasRequeridas(encerarPisos, [lustradpesora, cera, aspiradora(300)]).

% Agrego para probar la función del PUNTO III
herramientasRequeridas(programar,[[pc,laptop],teclado,mouse]).

% Agregado para el PUNTO VI
herramientasRequeridas(ordenarCuarto, [[aspiradora(100),escoba], trapeador, plumero]).


% PUNTO I

% tiene/2: tiene(Persona, Herramienta)

tiene(egon,aspiradora(200)).
tiene(egon,trapeador).
tiene(peter,trapeador).

% Ray y Winston no tienen un trapeador, por ende no se agrega a la base de conocimientos (principio de universo cerrado).

tiene(winston,varitaDeNeutrones).

% Nadie tiene una bordeadora, por ende no se agrega a la base de conocimientos (principio de universo cerrado).

% Agrego para probar la función del PUNTO III

tiene(lucas,pc).
tiene(lucas,teclado).
tiene(lucas,mouse).

% PUNTO II

esAspiradora(aspiradora(_)).

satisfaceNecesidad(Persona,Herramienta):-
    tiene(Persona,Herramienta),
    not(esAspiradora(Herramienta)).

satisfaceNecesidad(Persona,aspiradora(PotenciaRequerida)):-
    tiene(Persona,aspiradora(Potencia)),
    between(0, Potencia, PotenciaRequerida).

satisfaceNecesidad(Persona,Sublista):-
    member(Herramienta,Sublista),
    satisfaceNecesidad(Persona,Herramienta).

% PUNTO III

puedeHacerTarea(Persona,_):-
    tiene(Persona,varitaDeNeutrones).

puedeHacerTarea(Persona,Tarea):-
    tiene(Persona,_),
    herramientasRequeridas(Tarea,Herramientas),
    forall((member(Herramienta,Herramientas)),(satisfaceNecesidad(Persona,Herramienta))).

% PUNTO IV

% tareaPedida/3: tareaPedida(Cliente, Tarea, m2)

tareaPedida(aguluc,limpiarTecho,200).
tareaPedida(aguluc,limpiarTecho,100).

% precio/2 : precio(Tarea, Precio por m2)

precio(limpiarTecho,500).

precioACobrar(Cliente,Tarea,Precio):-
    tareaPedida(Cliente,Tarea,M2), 
    precio(Tarea,PrecioM2), 
    Precio is M2 * PrecioM2.

cobranza(Cliente,Cobranza):-
    tareaPedida(Cliente,_,_),
    findall(Precio, (precioACobrar(Cliente,_,Precio)), Precios),
    sumlist(Precios,Cobranza).

% PUNTO V

esCompleja(limpiarTecho).

esCompleja(Tarea):-
    herramientasRequeridas(Tarea,Herramientas),
    length(Herramientas, CantidadHerramientas),
    CantidadHerramientas > 2.

pideTareaCompleja(Cliente):-
    tareaPedida(Cliente,Tarea,_),
    esCompleja(Tarea).

dispuesto(ray,Cliente):-
    not(tareaPedida(Cliente,limpiarTecho,_)).

dispuesto(winston,Cliente):-
    cobranza(Cliente,Cobranza),
    Cobranza > 500.

dispuesto(egon,Cliente):-
    not(pideTareaCompleja(Cliente)).

aceptaPedido(Integrante,Cliente):-
    tiene(Integrante,_),
    tareaPedida(Cliente,_,_),
    dispuesto(Integrante,Cliente),
    forall((tareaPedida(Cliente,Tarea,_)),(puedeHacerTarea(Integrante,Tarea))).


