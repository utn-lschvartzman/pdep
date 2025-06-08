/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% PUNTO I

% ia/1: ia(Modelo de IA)

ia(pgt).
ia(piscis).
ia(pongAi).

% pais/2: pais(País de Origen, Modelo de Ia)

pais(chile,pongAi).

% valor/3: valor(Palabra, Valor, Ia)

valor(perro,2112,pgt).
valor(perro,2510,piscis).
valor(perro,2510,pongAi).

valor(gato,2215,pgt).
valor(gato,2215,piscis).
valor(gato,2215,pongAi).

valor(comida,2450,pgt).
valor(comida,2700,piscis).
valor(comida,2492,pongAi).

valor(morfi,2452,pgt).
valor(morfi,2721,piscis).
% La palabra "morfi" no existe para Pong AI, por ende no se agrega a la base de conocimientos (Principio de Universo Cerrado)

valor(corcho,1852,pgt).
valor(corcho,1918,piscis).
valor(corcho,1918,pongAi).

valor(tilin,8989,pgt).

% La palabra “MartínEsElMejorProfe” no existe en ningún modelo, por ende no se agrega a la base de conocimientos (Principio de Universo Cerrado)

% PUNTO II

noLaSabeNadie(Palabra):-
    not(valor(Palabra,_,_)).

% PUNTO III

palabra(Palabra):-
    valor(Palabra,_,_).

noSabe(Palabra,Modelo):-
    ia(Modelo),
    palabra(Palabra),
    not(valor(Palabra,_,Modelo)).

dificil(Palabra):-
    noSabe(Palabra,Modelo),
    noSabe(Palabra,Otro),
    Modelo \= Otro.

% PUNTO IV

diferenciaEntrePalabras(Palabra1,Palabra2,Modelo,Diferencia):-
    valor(Palabra1,Valor1,Modelo),
    valor(Palabra2,Valor2,Modelo),
    Palabra1 \= Palabra2,
    Diferencia is abs(Valor1 - Valor2).

cercanas(Palabra1,Palabra2,Modelo):-
    diferenciaEntrePalabras(Palabra1,Palabra2,Modelo,Diferencia),
    Diferencia < 200.

% PUNTO V

sinonimo(Palabra,Otra,Modelo):-
    diferenciaEntrePalabras(Palabra,Otra,Modelo,Diferencia),
    (Palabra \= paradigmas, Otra \= paradigmas),
    Diferencia < 20.

sinonimo(cosito,Palabra,Modelo):-
    valor(Palabra,Valor,Modelo),
    (Palabra \= paradigmas),
    between(1800,2100,Valor).

% PUNTO VI

menosBot(Modelo,Palabra1,Palabra2):-
    diferenciaEntrePalabras(Palabra1,Palabra2,Modelo,Distancia),
    forall((diferenciaEntrePalabras(Palabra1,Palabra2,OtroModelo,OtraDistancia), Modelo \= OtroModelo), (Distancia < OtraDistancia)).

% PUNTO VII

cantidadSinonimos(Palabra,Modelo,Cantidad):-
    palabra(Palabra),
    findall(_,sinonimo(Palabra,_,Modelo),Sinonimos),
    length(Sinonimos, Cantidad).

comodin(Palabra,Modelo):-
    cantidadSinonimos(Palabra,Modelo,Sinonimos),
    forall((cantidadSinonimos(Otra,Modelo,OtrosSinonimos), Palabra \= Otra), Sinonimos >= OtrosSinonimos).

% PUNTO VIII

perfil(pedro, programador(ruby, 5)).
perfil(maria, estudiante(programacion)).
perfil(sofia, estudiante(psicologia)).
perfil(juan, hijoDePapi).

relevanteSegunPerfil(hijoDePapi,Palabra,Modelo):-
    sinonimo(guita,Palabra,Modelo).

relevanteSegunPerfil(programador(Lenguaje,Experiencia),Palabra,Modelo):-
    cercanas(Lenguaje,Palabra,Modelo). % Está mal pero no se me ocurre cómo hacerlo, no tengo tiempo :s

relevanteSegunPerfil(estudiante(programacion),Palabra,Modelo):-
    relevanteSegunPerfil(programador(wollok,1),Palabra,Modelo).

relevanteSegunPerfil(estudiante(Tema),Palabra,Modelo):-
    Tema \= programacion,
    cercanas(Tema,Palabra,Modelo).

relevante(Palabra,Persona,Modelo):-
    perfil(Persona,Perfil),
    relevanteSegunPerfil(Perfil,Palabra,Modelo).

% PUNTO IX

gusta(juan, plata).
gusta(maria, joda).
gusta(maria, tarjeta).
gusta(inia, estudiar).
gusta(bauti, utn).
gusta(martin, comer).

relacionado(plata, gastar).
relacionado(gastar, tarjeta).
relacionado(tarjeta, viajar).
relacionado(estudiar, utn).
relacionado(utn, titulo).
relacionado(tarjeta, finanzas).

seRelaciona(Tema,Otro):-
    relacionado(Tema, Otro).

seRelaciona(Tema,Otro):-
    relacionado(Tema, Intermedio),
    seRelaciona(Intermedio,Otro).

leInteresa(Tema,Persona):-
    gusta(Persona,Tema).

leInteresa(Tema,Persona):-
    gusta(Persona,Algo),
    seRelaciona(Algo,Tema).
