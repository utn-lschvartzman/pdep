/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% PARTE I

% tipo/2: tipo(Pokemon, Tipo)

tipo(pikachu,electrico).
tipo(charizard,fuego).
tipo(venusaur,planta).
tipo(blastoise,agua).
tipo(totodile,agua).
tipo(snorlax,normal).
tipo(rayquaza,dragon).
tipo(rayquaza,volador).

% Como de Arceus no sabemos el tipo, no lo agregamos

pokemon(arceus). % No sabemos el tipo de Arceus, pero sí es un pokemon.
pokemon(Pokemon):-
    tipo(Pokemon,_).

% tiene/2: tiene(Entrenador, Pokemon que tiene)

tiene(ash,pikachu).
tiene(ash,charizard).
tiene(brock,snorlax).
tiene(misty,blastoise).
tiene(misty,venusaur).
tiene(misty,arceus).

% PUNTO I

tipoMultiple(Pokemon):-
    tipo(Pokemon,Tipo),
    tipo(Pokemon,OtroTipo),
    Tipo \= OtroTipo.

% PUNTO II

nadieLoTiene(Pokemon):-
    pokemon(Pokemon),
    not(tiene(_,Pokemon)).

esLegendario(Pokemon):-
    tipoMultiple(Pokemon),
    nadieLoTiene(Pokemon).

% PUNTO III

multipleEnSuTipo(Pokemon):-
    tipo(Pokemon,Tipo),
    tipo(Otro,Tipo),
    Pokemon \= Otro.

unicoEnSuTipo(Pokemon):-
    pokemon(Pokemon),
    not(multipleEnSuTipo(Pokemon)).

% Otra alternativa para PUNTO III
unicoEnSuTipoAlternativa(Pokemon):-
    tipo(Pokemon,Tipo),
    forall((tipo(Otro,SuTipo), Pokemon \= Otro), Tipo \= SuTipo).

esMisterioso(Pokemon):-
    unicoEnSuTipo(Pokemon).

esMisterioso(Pokemon):-
    nadieLoTiene(Pokemon).

% PARTE II

% movimiento/2: movimiento(Nombre, Accion) - Accion es un functor

movimiento(mordedura,fisico(95)).
movimiento(impactrueno,especial(electrico,40)).
movimiento(garraDragon,especial(dragon,100)).
movimiento(proteccion,defensivo(10)).
movimiento(placaje,fisico(50)).
movimiento(alivio,defensivo(100)).

% puedeUsar/2: puedeUsar(Pokemon, Movimiento)

puedeUsar(pikachu,mordedura).
puedeUsar(pikachu,impactrueno).
puedeUsar(charizard,garraDragon).
puedeUsar(charizard,mordedura).
puedeUsar(blastoise,proteccion).
puedeUsar(blastoise,placaje).
puedeUsar(arceus,impactrueno).
puedeUsar(arceus,garraDragon).
puedeUsar(arceus,proteccion).
puedeUsar(arceus,placaje).
puedeUsar(arceus,alivio).

% Snorlax no puede usar ningún movimiento, entonces no se agrega.

% PUNTO I

% Los tipos básicos son los siguientes
esBasico(agua).
esBasico(fuego).
esBasico(planta).
esBasico(normal).

% El multiplicador de daño por tipo (de Pokemón)
multiplicador(Tipo,1.5):-
    esBasico(Tipo).

multiplicador(dragon,3).

multiplicador(Tipo,1):-
    Tipo \= dragon,
    not(esBasico(Tipo)).

% El daño de cada tipo de movimiento (es decir, la acción en sí)

danio(fisico(Potencia),Potencia).
danio(defensivo(_),0).
danio(especial(Tipo,Potencia),Danio):-
    multiplicador(Tipo,Multiplicador),
    Danio is Potencia * Multiplicador.

danioAtaque(Movimiento,Danio):-
    movimiento(Movimiento,Accion),
    danio(Accion,Danio).

% PUNTO II

capacidadOfensiva(Pokemon,Capacidad):-
    pokemon(Pokemon),
    findall(Danio,(puedeUsar(Pokemon,Movimiento),danioAtaque(Movimiento,Danio)),Danios),
    sumlist(Danios,Capacidad).

% PUNTO III

pokemonPicante(Pokemon):-
    capacidadOfensiva(Pokemon,Capacidad),
    Capacidad > 200.

pokemonPicante(Pokemon):-
    esMisterioso(Pokemon).

esPicante(Entrenador):-
    tiene(Entrenador,_),
    forall((tiene(Entrenador,Pokemon)),pokemonPicante(Pokemon)).

% Alternativa para el PUNTO III

tienePokemonNoPicante(Entrenador):-
    tiene(Entrenador,Pokemon),
    not(pokemonPicante(Pokemon)).

esPicanteAlternativa(Entrenador):-
    tiene(Entrenador,_),
    not(tienePokemonNoPicante(Entrenador)).