/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% PUNTO I

% canal/3: canal(Dueño, Plataforma, Seguidores)

% Canales de Ana
canal(ana,youtube,3000000).
canal(ana,instagram,2700000).
canal(ana,tiktok,1000000).
canal(ana,twitch,2).

% Canales de Beto

canal(beto,twitch,120000).
canal(beto,youtube,6000000).
canal(beto,instagram,1100000).

% No tiene canal de TikTok, no se agrega (Principio de Universo Cerrado).

% Canales de Cami

canal(cami,tiktok,2000).

% Idem para los otros canales que no tiene Cami

% Canales de Dani

canal(dani,youtube,1000000).

% Canales de Evelyn

canal(evelyn,instagram,1).

% PUNTO II - A

seguidoresTotales(Usuario,Total):-
    findall(Seguidores,(canal(Usuario,_,Seguidores)),SeguidoresTotales),
    sumlist(SeguidoresTotales,Total).

influencer(Usuario):-
    canal(Usuario,_,_),
    seguidoresTotales(Usuario,Seguidores),
    Seguidores > 10000.

% PUNTO II - B

estaEnTodasLasRedes(Influencer):-
    forall(canal(_,Red,_),canal(Influencer,Red,_)).

omnipresente(Influencer):-
    influencer(Influencer),
    estaEnTodasLasRedes(Influencer).

% PUNTO II - C

estaEnUnaSolaRed(Influencer):-
    findall(Red,canal(Influencer,Red,_),Redes),
    length(Redes,1).

exclusivo(Influencer):-
    influencer(Influencer),
    estaEnUnaSolaRed(Influencer).

% PUNTO III

publico(ana,tiktok,video(1,[beto,evelyn])).
publico(ana,tiktok,video(1,[ana])).
publico(ana,instagram,foto([ana])).

publico(beto,instagram,foto([])).

publico(cami,twitch,stream(Tematica)):-
    tematica(Tematica,leagueOfLegends).

publico(cami,youtube,video(5,[cami])).

publico(evelyn,instagram,foto([cami,evelyn])).

tematica(juegos,leagueOfLegends).
tematica(juegos,minecraft).
tematica(juegos,aoe).

% PUNTO IV

esAdictivo(video(Minutos,_)):-
    Minutos < 3.

esAdictivo(stream(juegos)).

esAdictivo(foto(Participantes)):-
    length(Participantes,Cantidad),
    Cantidad < 4.

adictiva(Red):-
    publico(_,Red,_),
    forall(publico(_,Red,Contenido),esAdictivo(Contenido)).

% PUNTO V - No estoy seguro, la verdad este punto es muy AMBIGUO

colaboracion(Usuario,OtroUsuario):-
    publico(OtroUsuario,_,video(_,Participantes)),
    member(Usuario,Participantes).

colaboracion(Usuario,OtroUsuario):-
    publico(OtroUsuario,_,foto(Participantes)),
    member(Usuario,Participantes).

colaboracion(Usuario,OtroUsuario):-
    publico(Usuario,_,stream(Tematica)),
    publico(OtroUsuario,_,stream(Tematica)).

colaboro(Usuario,OtroUsuario):-
    colaboracion(Usuario,OtroUsuario).

colaboro(OtroUsuario,Usuario):-
    colaboracion(Usuario,OtroUsuario).

colaboran(Usuario,OtroUsuario):-
    publico(Usuario,_,_),
    publico(OtroUsuario,_,_),
    colaboro(Usuario,OtroUsuario),
    Usuario \= OtroUsuario.

% PUNTO VI

aparece(Usuario):-
    influencer(Influencer),
    colaboran(Influencer,Usuario).

aparece(Usuario):-
    influencer(Influencer),
    colaboran(Usuario,Intermedio),
    colaboran(Intermedio,Influencer).

caminoALaFama(Usuario):-
    publico(Usuario,_,_),
    not(influencer(Usuario)),
    aparece(Usuario).

% PUNTO VII

:- begin_tests(parcial).

test('Beto es influencer', nondet):-
  influencer(beto).

:- end_tests(parcial).

% VII - B: Si Beto no tiene TikTok, no se agrega (principio de universo cerrado)