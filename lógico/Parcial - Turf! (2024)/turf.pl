/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% PUNTO I

% jockey/3: jockey(Nombre,Altura,Peso)

jockey(valdivieso,155,52).
jockey(leguisamo,161,49).
jockey(lezcano,149,50).
jockey(baratucci,153,55).
jockey(falero,157,52).
jockey(lucas,178,75).

% caballo/1: caballo(Caballo) - Si es necesario lo implemento, si no, no.

% preferencia/2: preferencia(Caballo,Preferencia)

preferencia(botafogo,baratucci).

preferencia(botafogo,Jockey):-
    jockey(Jockey,_,Peso),
    Peso < 52.

preferencia(oldman,Jockey):-
    jockey(Jockey,_,_),
    atom_length(Jockey, CantidadLetras),
    CantidadLetras > 7.

preferencia(energica,Jockey):-
    jockey(Jockey,_,_),
    not(preferencia(botafogo,Jockey)).

preferencia(matboy,Jockey):-
    jockey(Jockey,Altura,_),
    Altura > 170.

% Yatasto no tiene preferencias, entonces no se agrega a la base de conocimientos (principio de universo cerrado).

% stud/2: stud(Jockey,Stud)

stud(valdivieso,elTute).
stud(falero,elTute).
stud(lezcano,lasHormigas).
stud(baratucci,elCharabon).
stud(leguisamo,elCharabon).
stud(lucas,leProlog).

% gano/2: gano(Caballo,Premio)

gano(botafogo,granPremioNacional).
gano(botafogo,granPremioRepublica).
gano(oldman,granPremioRepublica).
gano(oldman,campeonatoPalermoDeOro).
gano(matboy,granPremioCriadores).

% Enérgica y Yatasto no ganaron ningún campeonato, entonces no se agrega a la base de conocimientos (principio de universo cerrado).

% PUNTO II

prefiereAMasDeUno(Caballo):-
    preferencia(Caballo,Jockey),
    preferencia(Caballo,OtroJockey),
    Jockey \= OtroJockey.

% PUNTO III

aborrece(Caballo,Stud):-
    preferencia(Caballo,_),
    stud(_,Stud),
    forall((stud(Jockey,Stud)),(not(preferencia(Caballo,Jockey)))).

% Resolución alternativa a PUNTO III

prefiereAlgunoDeStud(Caballo,Stud):-
    stud(Jockey,Stud),
    preferencia(Caballo,Jockey).

aborreceAlternativa(Caballo,Stud):-
    preferencia(Caballo,_),
    stud(_,Stud),
    not(prefiereAlgunoDeStud(Caballo,Stud)).

% PUNTO IV

% premioImportante/1: premioImportante(Premio) - Si el premio es importante

premioImportante(granPremioNacional).
premioImportante(granPremioRepublica).

caballoImportante(Caballo):-
    gano(Caballo,Premio),
    premioImportante(Premio).

esPiolin(Jockey):-
    jockey(Jockey,_,_),
    forall(caballoImportante(Caballo),preferencia(Caballo,Jockey)).

% PUNTO V

ganadora(ganador(Caballo), Resultado):-
    salioPrimero(Caballo, Resultado).

ganadora(segundo(Caballo), Resultado):-
    salioPrimero(Caballo, Resultado).

ganadora(segundo(Caballo), Resultado):-
    salioSegundo(Caballo, Resultado).

ganadora(exacta(Caballo1, Caballo2)):-
    salioPrimero(Caballo1, Resultado), 
    salioSegundo(Caballo2, Resultado).

ganadora(imperfecta(Caballo1, Caballo2)):-
    salioPrimero(Caballo1, Resultado), 
    salioSegundo(Caballo2, Resultado).

ganadora(imperfecta(Caballo1, Caballo2)):-
    salioPrimero(Caballo2, Resultado), 
    salioSegundo(Caballo1, Resultado).

salioPrimero(Caballo, [Caballo|_]).
salioSegundo(Caballo, [_|[Caballo|_]]).

% PUNTO VI

% color/2: color(Nombre, Elemento que lo compone)

color(tordo,negro).
color(alazan,marron).
color(ratonero,gris).
color(ratonero,negro).
color(palomino,marron).
color(palomino,blanco).
color(yatasto,marron).
color(yatasto,blanco).

% crin/2: crin(Caballo,Color)

crin(botafogo,tordo).
crin(oldman,alazan).
crin(energica,ratonero).
crin(matboy,palomino).
crin(yatasto,pinto).

caballosDeColor(Color,Combinacion):-
    findall(Caballo,(color(Crin,Color),crin(Caballo,Crin)),Caballos),
    combinar(Caballos,Combinacion),
    Caballos \= [].

combinar([], []).
combinar([Caballo|CaballosPosibles], [Caballo|Caballos]):- combinar(CaballosPosibles, Caballos).
combinar([_|CaballosPosibles], Caballos):-combinar(CaballosPosibles, Caballos).

