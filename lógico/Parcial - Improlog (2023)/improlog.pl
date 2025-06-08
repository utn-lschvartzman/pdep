/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% integrante/3:(grupo,persona,instrumento que toca en el grupo)
integrante(sophieTrio,sophie,violin).
integrante(sophieTrio,santi,guitarra).
integrante(vientosDelEste,lisa,saxo).
integrante(vientosDelEste,santi,voz).
integrante(vientosDelEste,santi,guitarra).
integrante(jazzmin,santi,bateria).

integrante(prolog,lucas,guitarra).
integrante(prolog,sofia,bateria).

% nivelQueTiene/3: (persona,instrumento,qué tan bien puede improvisar)
nivelQueTiene(sophie,violin,5).
nivelQueTiene(santi,guitarra,2).
nivelQueTiene(santi,voz,3).
nivelQueTiene(santi,bateria,4).
nivelQueTiene(lisa,saxo,4).
nivelQueTiene(santi,bateria,4).
nivelQueTiene(lore,violin,4).
nivelQueTiene(luis,trompeta,1).
nivelQueTiene(luis,contrabajo,4).

% instrumento/2: (instrumento,tipo)
instrumento(violin,melodico(cuerdas)).
instrumento(guitarra,armonico).
instrumento(bateria,ritmico).
instrumento(saxo,melodico(viento)).
instrumento(trompeta,melodico(viento)).
instrumento(contrabajo,ritmico).
instrumento(bajo,armonico).
instrumento(piano,armonico).
instrumento(pandereta,ritmico).
instrumento(voz,melodico(vocal)).

% PUNTO I

tieneBuenaBase(Grupo):-
    integrante(Grupo,IntegranteRitmico,InstrumentoRitmico),
    integrante(Grupo,IntegranteArmonico,InstrumentoArmonico),
    instrumento(InstrumentoRitmico,ritmico),
    instrumento(InstrumentoArmonico,armonico),
    IntegranteRitmico \= IntegranteArmonico.

% PUNTO II

nivelEnGrupo(Persona,Grupo,Nivel):-
    integrante(Grupo,Persona,Instrumento),
    nivelQueTiene(Persona,Instrumento,Nivel).

seDestaca(Destacado,Grupo):-
    nivelEnGrupo(Destacado,Grupo,NivelDestacado),
    forall((nivelEnGrupo(Persona,Grupo,Nivel),Persona \= Destacado),((NivelDestacado - 2) >= Nivel)).

% PUNTO III

grupo(vientosDelEste,bigband).
grupo(sophieTrio,formacion([contrabajo,guitarra,violin])).
grupo(jazzmin,formacion([bateria,bajo,trompeta,piano,guitarra])).

% PUNTO VIII - Agregado

% ensamble(Nivel Minimo)
grupo(prolog,ensamble(5)).

% PUNTO IV

faltaInstrumento(Instrumento,Grupo):-
    instrumento(Instrumento,_),
    grupo(Grupo,_),
    not(integrante(Grupo,_,Instrumento)).

esDeViento(Instrumento):-
    instrumento(Instrumento,melodico(viento)).

hayCupo(Instrumento,Grupo):-
    grupo(Grupo,bigband),
    esDeViento(Instrumento).

hayCupo(Instrumento,Grupo):-
    faltaInstrumento(Instrumento,Grupo),
    grupo(Grupo,Tipo),
    sirve(Instrumento,Tipo).

sirve(Instrumento,formacion(InstrumentosRequeridos)):-
    member(Instrumento,InstrumentosRequeridos).

sirve(Instrumento,bigband):-
    esDeViento(Instrumento).

sirve(bateria,bigband).
sirve(bajo,bigband).
sirve(piano,bigband).

sirve(_,ensamble(_)).

% PUNTO V

nivelEsperado(bigband,1).

nivelEsperado(formacion(InstrumentosRequeridos),NivelEsperado):-
    length(InstrumentosRequeridos,CantidadInstrumentos),
    NivelEsperado is 7 - CantidadInstrumentos.

nivelEsperado(ensamble(NivelEsperado),NivelEsperado).

puedeIncorporarse(Persona,Instrumento,Grupo):-
    not(integrante(Grupo,Persona,_)),
    hayCupo(Instrumento,Grupo),
    nivelQueTiene(Persona,Instrumento,Nivel),
    grupo(Grupo,Tipo),
    nivelEsperado(Tipo,NivelEsperado),
    Nivel >= NivelEsperado.

% PUNTO VI

quedoEnBanda(Persona):-
    nivelQueTiene(Persona,_,_),
    not(integrante(_,Persona,_)),
    not(puedeIncorporarse(Persona,_,_)).

% PUNTO VII

cubreNecesidad(Grupo):-
    grupo(Grupo,bigband),
    tieneBuenaBase(Grupo),
    findall(_,(integrante(Grupo,_,Instrumento),esDeViento(Instrumento)),InstrumentosDeViento),
    length(InstrumentosDeViento,CantidadDeViento),
    CantidadDeViento >= 5.

cubreNecesidad(Grupo):-
    grupo(Grupo,formacion(InstrumentosRequeridos)),
    forall(member(InstrumentosRequeridos,Requerido),integrante(Grupo,_,Requerido)).

cubreNecesidad(Grupo):-
    grupo(Grupo,ensamble(_)),
    tieneBuenaBase(Grupo),
    integrante(Grupo,_,InstrumentoMelodico),
    instrumento(InstrumentoMelodico,melodico(_)).

puedeTocar(Grupo):-
    cubreNecesidad(Grupo).

% PUNTO VIII

% Ver mas arriba en el código, este punto era ajustar funciones anteriores.