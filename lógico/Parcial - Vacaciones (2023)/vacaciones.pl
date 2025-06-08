/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% PUNTO I

% viaja/2: viaja(Persona, Destino)

viaja(dodain,pehuenia).
viaja(dodain,sanMartinDeLosAndes).
viaja(dodain,esquel).
viaja(dodain,sarmiento).
viaja(dodain,camarones).
viaja(dodain,playasDoradas).
viaja(alf,bariloche).
viaja(alf,sanMartinDeLosAndes).
viaja(alf,elBolson).
viaja(nico,marDelPlata).
viaja(vale,calafate).
viaja(vale,elBolson).

viaja(martu,Destino):-
    viaja(nico,Destino).

viaja(martu,Destino):-
    viaja(alf,Destino).

viaja(lucas,buenosAires).
viaja(lucas,neuquen).

% - Juan no sabe si va a ir a Villa Gesell o a Federación.
% - Carlos no se va a tomar vacaciones por ahora. 

% Como ambos no son HECHOS, no se agregan a la base de conocimientos (principio de universo cerrado).

persona(Persona):-
    viaja(Persona,_).

% PUNTO II

sePuedePescar("Moquehue").
sePuedePescar("Aluminé").

% atraccion/2: atraccion(Lugar, Atraccion) - Con Atraccion siendo un functor para admitir POLIMORFISMO

atraccion(esquel,parqueNacional("Los Alerces")).
atraccion(esquel,excursion("Trochita")).
atraccion(esquel,excursion("Trevelin")).
atraccion(pehuenia,cerro("Batea Mahuida",2000)).
atraccion(pehuenia,cuerpoAgua("Moquehue",14)).
atraccion(pehuenia,cuerpoAgua("Aluminé",19)).

atraccion(buenosAires,parqueNacional("Prolog")).
atraccion(neuquen,cerro("Cerro Prolog",5000)).

% Agrego una playa:
atraccion(gesell,playa(5,9)).

copada(cerro(_,Metros)):-
    Metros > 2000.

copada(cuerpoAgua(Cuerpo,Temperatura)):-
    sePuedePescar(Cuerpo),
    Temperatura > 20.

copada(playa(MareaBaja,MareaAlta)):-
    abs(MareaBaja - MareaAlta) < 5.

copada(excursion(Nombre)):-
    string_length(Nombre, Letras),
    Letras > 7.

copada(parqueNacional(_)).

% ADVERTENCIA: Este punto es muy ambiguo, a partir de acá el parcial es SUPONIENDO cómo se deben tratar las vacaciones (puede estar mal TODO).

% Suponiendo que las VACACIONES son todos los viajes que una persona hizo (viaja/2)

destinoCopado(Destino):-
    atraccion(Destino,Atraccion),
    copada(Atraccion).

lugaresVisitados(Persona,Cantidad):-
    findall(Destino,(viaja(Persona,Destino)),Destinos),
    length(Destinos,Cantidad).

vacacionesCopadas(Persona,Vacaciones):-
    persona(Persona),
    findall(Destino,(viaja(Persona,Destino),destinoCopado(Destino)),Destinos),
    list_to_set(Destinos,Vacaciones),
    lugaresVisitados(Persona,Cantidad),
    length(Vacaciones,Cantidad).

% Suponiendo que las VACACIONES son los viajes que son copados

vacacionesCopadasV2(Persona,Vacaciones):-
    persona(Persona),
    findall(Destino,(viaja(Persona,Destino),destinoCopado(Destino)),Vacaciones).

% PUNTO III

seCruzaron(Persona1,Persona2):-
    viaja(Persona1,Destino),
    viaja(Persona2,Destino).

noSeCruzaron(Persona1,Persona2):-
    persona(Persona1),
    persona(Persona2),
    Persona1 \= Persona2,
    not(seCruzaron(Persona1,Persona2)).

% Alternativa para el PUNTO III

noSeCruzaronAlternativa(Persona1,Persona2):-
    persona(Persona1),
    persona(Persona2),
    Persona1 \= Persona2,
    forall(viaja(Persona1,Destino),not(viaja(Persona2,Destino))).

% PUNTO IV

costoVida(sarmiento,100).
costoVida(esquel,150).
costoVida(pehuenia,180).
costoVida(sanMartinDeLosAndes,150).
costoVida(camarones,135).
costoVida(playasDoradas,170).
costoVida(bariloche,140).
costoVida(calafate,240).
costoVida(elBolson,145).
costoVida(marDelPlata,140).

esGasolero(Destino):-
    costoVida(Destino,CostoVida),
    CostoVida < 160.

vacacionesGasoleras(Persona):-
    persona(Persona),
    forall(viaja(Persona,Destino),esGasolero(Destino)).

% PUNTO V

itinerariosPosibles(Persona,Itinerario):-
    persona(Persona),
    findall(Destino,viaja(Persona,Destino),Destinos),
    permutation(SinRepetir, Itinerario).
