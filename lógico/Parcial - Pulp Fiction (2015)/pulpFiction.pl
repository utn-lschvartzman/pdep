/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% personaje/2: personaje(Nombre, Actividad)
personaje(pumkin,ladron([licorerias, estacionesDeServicio])).
personaje(honeyBunny,ladron([licorerias, estacionesDeServicio])).
personaje(vincent,mafioso(maton)).
personaje(jules,mafioso(maton)).
personaje(marsellus,mafioso(capo)).
personaje(winston,mafioso(resuelveProblemas)).
personaje(mia,actriz([foxForceFive])).
personaje(butch,boxeador).

% pareja/2: pareja(Integrante1, Integrante2)
pareja(marsellus,mia).
pareja(pumkin,honeyBunny).

% trabajaPara/2: trabajaPara(Empleador, Empleado)
trabajaPara(marsellus,vincent).
trabajaPara(marsellus,jules).
trabajaPara(marsellus,winston).

% PUNTO I

actividadPeligrosa(ladron(Lugares)):-
    member(licorerias,Lugares).

actividadPeligrosa(mafioso(maton)).

esPeligroso(Personaje):-
    personaje(Personaje,Actividad),
    actividadPeligrosa(Actividad).

esPeligroso(Personaje):-
    trabajaPara(Personaje,Empleado),
    esPeligroso(Empleado).

% PUNTO II

amigo(vincent, jules).
amigo(jules, jimmie).
amigo(vincent, elVendedor).

% seRelacionan/2 es SIMÉTRICO, es decir: Si A se relaciona con B, entonces B se relaciona con A.

sonAmigos(Persona,Otra):-
    amigo(Persona,Otra).

sonAmigos(Persona,Otra):-
    amigo(Otra,Persona).

seRelacionan(Personaje1,Personaje2):-
    sonAmigos(Personaje1,Personaje2).

seRelacionan(Personaje1,Personaje2):-
    pareja(Personaje1,Personaje2).

seRelacionan(Personaje1,Personaje2):-
    pareja(Personaje2,Personaje1).

duoTemible(Personaje1,Personaje2):-
    esPeligroso(Personaje1),
    esPeligroso(Personaje2),
    seRelacionan(Personaje1,Personaje2).

% PUNTO III

% encargo/3: encargo(Solicitante, Encargado, Tarea).

% Las tareas pueden ser cuidar(Protegido), ayudar(Ayudado), buscar(Buscado, Lugar)

encargo(marsellus, vincent,   cuidar(mia)).
encargo(vincent,  elVendedor, cuidar(mia)).
encargo(marsellus, winston, ayudar(jules)).
encargo(marsellus, winston, ayudar(vincent)).
encargo(marsellus, vincent, buscar(butch, losAngeles)).

% Agrego este encargo para que exista alguien más atareado que el resto.
encargo(marsellus, vincent, ayudar(mia)).

jefePeligroso(Jefe,Personaje):-
    trabajaPara(Jefe,Personaje),
    esPeligroso(Jefe).

estaEnProblemas(butch).

estaEnProblemas(Personaje):-
    jefePeligroso(Jefe,Personaje),
    pareja(Jefe,Pareja),
    encargo(Jefe,Personaje,cuidar(Pareja)).

estaEnProblemas(Personaje):-
    personaje(Boxeador,boxeador),
    encargo(_,Personaje,buscar(Boxeador)).

% PUNTO IV

tieneCerca(Persona,Otra):-
    sonAmigos(Persona,Otra).

tieneCerca(Persona,Otra):-
    trabajaPara(Persona,Otra).

sanCayetano(Persona):-
    personaje(Persona,_),
    forall(tieneCerca(Persona,Cercano),encargo(Persona,Cercano,_)).

% PUNTO V

encargosPersona(Persona,Cantidad):-
    encargo(_,Persona,_),
    findall(_,encargo(_,Persona,_),Encargos),
    length(Encargos, Cantidad).

masAtareado(Persona):-
    encargosPersona(Persona, Encargos),
    forall((encargosPersona(Otro,OtrosEncargos),Persona \= Otro), Encargos > OtrosEncargos).

% PUNTO VI

puntosMafioso(resuelveProblemas,10).
puntosMafioso(matones,1).
puntosMafioso(capo,20).

puntosRespeto(actriz(Peliculas),Puntos):-
    length(Peliculas,Cantidad),
    Puntos is (Cantidad / 10).

puntosRespeto(mafioso(Tipo),Puntos):-
    puntosMafioso(Tipo,Puntos).

esRespetable(Personaje):-
    personaje(Personaje,Actividad),
    puntosRespeto(Actividad,Respeto),
    Respeto > 9.

personajesRespetables(Respetables):-
    findall(Personaje,esRespetable(Personaje),Respetables).

% PUNTO VII

esPara(cuidar(Otro),Otro).
esPara(ayudar(Otro),Otro).
esPara(buscar(Otro,_),Otro).

interactua(Encargo,Persona):-
    esPara(Encargo,Persona).

interactua(Encargo,Persona):-
    sonAmigos(Persona,Amigo),
    esPara(Encargo,Amigo).

hartoDe(Personaje,Otro):-
    personaje(Personaje,_),
    personaje(Otro,_),
    Personaje \= Otro,
    forall(encargo(_,Personaje,Encargo),interactua(Encargo,Otro)).

% PUNTO VIII

caracteristicas(vincent,[negro, muchoPelo, tieneCabeza]).
caracteristicas(jules,[tieneCabeza, muchoPelo]).
caracteristicas(marvin,[negro]).

tieneFaltante(Integrante1,Integrante2):-
    caracteristicas(Integrante1,Caracteristicas1),
    caracteristicas(Integrante2,Caracteristicas2),
    member(Caractersitica,Caracteristicas1),
    not(member(Caractersitica,Caracteristicas2)).

seDiferencian(Integrante1,Integrante2):-
    tieneFaltante(Integrante1,Integrante2).

seDiferencian(Integrante1,Integrante2):-
    tieneFaltante(Integrante2,Integrante1).

duoDiferenciable(Integrante1,Integrante2):-
    seRelacionan(Integrante1,Integrante2),
    seDiferencian(Integrante1,Integrante2).
