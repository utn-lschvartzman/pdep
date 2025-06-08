/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% tarea/3: tarea(Agente, Tarea, Ubicación) - Tareas es un functor

/*
    Tareas disponibles:
    
    - ingerir(descripcion, tamaño, cantidad)
    - apresar(malviviente, recompensa)
    - asuntosInternos(agenteInvestigado)
    - vigilar(listaDeNegocios)
*/

tarea(vigilanteDelBarrio, ingerir(pizza, 1.5, 2),laBoca).
tarea(vigilanteDelBarrio, vigilar([pizzeria, heladeria]), barracas).
tarea(canaBoton, asuntosInternos(vigilanteDelBarrio), barracas).
tarea(sargentoGarcia, vigilar([pulperia, haciendaDeLaVega, plaza]),puebloDeLosAngeles).
tarea(sargentoGarcia, ingerir(vino, 0.5, 5),puebloDeLosAngeles).
tarea(sargentoGarcia, apresar(elzorro, 100), puebloDeLosAngeles). 
tarea(vega, apresar(neneCarrizo,50),avellaneda).
tarea(jefeSupremo, vigilar([congreso,casaRosada,tribunales]),laBoca).

% Agregado para el PUNTO VII
tarea(lucas, vigilar([negocioAlfajores]),almagro).

% ubicacion/1: ubicacion(Ubicacion)

% Las ubicaciones que existen son las siguientes:

ubicacion(puebloDeLosAngeles).
ubicacion(avellaneda).
ubicacion(barracas).
ubicacion(marDelPlata).
ubicacion(laBoca).
ubicacion(uqbar).

% Agregado para el PUNTO VII
ubicacion(almagro).

% jefe/2: jefe(Jefe, Subordinado).

jefe(jefeSupremo,vega ).
jefe(vega, vigilanteDelBarrio).
jefe(vega, canaBoton).
jefe(jefeSupremo,sargentoGarcia).

% Agregado para el PUNTO VII 

% Lucas es el jefe de todos (los agentes de la base de conocimiento), pero no de sí mismo (para cortar la cadena de mando)

jefe(lucas,Agente):-
    agente(Agente),
    Agente \= lucas.

% PUNTO I

agente(Agente):-
    tarea(Agente,_,_).

frecuenta(Agente,buenosAires):-
    agente(Agente).

frecuenta(vega,quilmes).

frecuenta(Agente,Ubicacion):-
    tarea(Agente,_,Ubicacion).

frecuenta(Agente,marDelPlata):-
    tarea(Agente,vigilar(Negocios),_),
    member(negocioAlfajores,Negocios).

% PUNTO II

lugarInaccesible(Lugar):-
    ubicacion(Lugar),
    not(frecuenta(_,Lugar)).

% PUNTO III - Utilizando NOT/1

trabajaEnDistintosLugares(Agente):-
    tarea(Agente,_,Lugar),
    tarea(Agente,_,Otro),
    Lugar \= Otro.

afincado(Agente):-
    agente(Agente),
    not(trabajaEnDistintosLugares(Agente)).

% Alternativa para PUNTO III - Utilizando FORALL/2

afincadoAlternativa(Agente):-
    tarea(Agente,Tarea,Lugar),
    forall((tarea(Agente,Otra,Lugar),Tarea \= Otra), tarea(Agente,Otra,Lugar)).

% PUNTO IV

hayCadena([]).
hayCadena([_]).
hayCadena([Primero , Segundo | Cadena]):-
    jefe(Primero,Segundo),
    hayCadena([Segundo | Cadena]).

cumpleMinimo(Cadena):-
    length(Cadena, Cantidad),
    Cantidad >= 2.

cadenaDeMando(Cadena):-
    hayCadena(Cadena),
    cumpleMinimo(Cadena).
    
% PUNTO V

puntos(vigilar(Negocios),Puntos):-
    length(Negocios,Cantidad),
    Puntos is 5 * Cantidad.

puntos(ingerir(_,Tamanio,Cantidad),Puntos):-
    Puntos is (-10) * (Tamanio * Cantidad).

puntos(apresar(_,Recompensa),Puntos):-
    Puntos is (Recompensa / 2).

puntos(asuntosInternos(Investigado),Puntos):-
    puntuacion(Investigado,Puntuacion),
    Puntos is (2 * Puntuacion).

puntuacion(Agente,Puntuacion):-
    agente(Agente),
    findall(Puntos,(tarea(Agente,Tarea,_),puntos(Tarea,Puntos)),Puntaje),
    sumlist(Puntaje,Puntuacion).

agentePremiado(Agente):-
    puntuacion(Agente,Puntuacion),
    forall((puntuacion(Otro,OtraPuntuacion),Agente \= Otro), Puntuacion > OtraPuntuacion).

% PUNTO VI

/*

    El polimorfismo es utilizado, por ejemplo para los trabajos, ya que son functores (de distintas formas).

    La inversibilidad está presente en todos los predicados principales, para poder hacer todos los tipos de
    consultas.

    El orden superior no está presente, y es más, no lo utilizamos en el paradigma lógico.

*/

% PUNTO VII

% Ver más arriba.