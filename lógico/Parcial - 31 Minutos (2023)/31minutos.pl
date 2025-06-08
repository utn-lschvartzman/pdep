/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% PARTE I: Canciones

% cancion/3: cancion(Cancion, Compositores, Reproducciones).

cancion(bailanSinCesar, [pabloIlabaca, rodrigoSalinas], 10600177).
cancion(yoOpino, [alvaroDiaz, carlosEspinoza, rodrigoSalinas], 5209110).
cancion(equilibrioEspiritual, [danielCastro, alvaroDiaz, pabloIlabaca, pedroPeirano, rodrigoSalinas], 12052254).
cancion(tangananicaTanganana, [danielCastro, pabloIlabaca, pedroPeirano], 5516191).
cancion(dienteBlanco, [danielCastro, pabloIlabaca, pedroPeirano], 5872927). 
cancion(lala, [pabloIlabaca, pedroPeirano], 5100530).
cancion(meCortaronMalElPelo, [danielCastro, alvaroDiaz, pabloIlabaca, rodrigoSalinas], 3428854).

% rankingTop3/3: rankingTop3(Mes, Puesto, Cancion)
rankingTop3(febrero, 1, lala).
rankingTop3(febrero, 2, tangananicaTanganana).
rankingTop3(febrero, 3, meCortaronMalElPelo).
rankingTop3(marzo, 1, meCortaronMalElPelo).
rankingTop3(marzo, 2, tangananicaTanganana).
rankingTop3(marzo, 3, lala).
rankingTop3(abril, 1, tangananicaTanganana).
rankingTop3(abril, 2, dienteBlanco).
rankingTop3(abril, 3, equilibrioEspiritual).
rankingTop3(mayo, 1, meCortaronMalElPelo).
rankingTop3(mayo, 2, dienteBlanco).
rankingTop3(mayo, 3, equilibrioEspiritual).
rankingTop3(junio, 1, dienteBlanco).
rankingTop3(junio, 2, tangananicaTanganana).
rankingTop3(junio, 3, lala).

% Agrego para testear hit(Cancion)
rankingTop3(mayo, 1, tangananicaTanganana).

% PUNTO I

mes(Mes):-
    rankingTop3(Mes,_,_).

hit(Cancion):-
    cancion(Cancion,_,_),
    forall(mes(Mes),rankingTop3(Mes,_,Cancion)).

% PUNTO II

tieneMuchasReproducciones(Cancion):-
    cancion(Cancion,_,Reproducciones),
    Reproducciones > 7000000.

noEsReconocidaPorCriticos(Cancion):-
    tieneMuchasReproducciones(Cancion),
    not(rankingTop3(_,_,Cancion)).

% PUNTO III

sonColaboradores(Compositor1,Compositor2):-
    cancion(_,Compositores,_),
    (member(Compositor1,Compositores),member(Compositor2,Compositores)),
    Compositor1 \= Compositor2.

% PARTE II: Trabajos

% trabajo/2: trabajo(Persona,Trabajo) - Trabajo es un functor para admitir POLIMORFISMO

/*

    FUNCTORES DE TRABAJO:

    conductor(Años de Experiencia).
    periodista(Años de Experiencia, Título (Licenciatura o Posgrado)).
    reportero(Años de Experiencia, Cantidad de Notas Hechas).

*/

% PUNTO IV

trabajo(tulio,conductor(5)).
trabajo(bodoque,periodista(2,licenciatura)).
trabajo(bodoque,reportero(5,300)).
trabajo(marioHugo,periodista(10,posgrado)).
trabajo(juanin,conductor(0)).

% Agregado del PUNTO VI

% programador(Lenguaje, Líneas de Código Escritas)
trabajo(lucas,programador(prolog,5600)).
trabajo(lucas,programador(c,8000)).

esAltoNivel(prolog).

esBajoNivel(Lenguaje):-
    not(esAltoNivel(Lenguaje)).

% ---------------------

% PUNTO V

persona(Persona):-
    trabajo(Persona,_).

sueldoTrabajo(conductor(Anios),Sueldo):-
    Sueldo is 10000 * Anios.

sueldoTrabajo(reportero(Anios,Notas),Sueldo):-
    Sueldo is (10000 * Anios) + (100 * Notas).

sueldoTrabajo(periodista(Anios,licenciatura),Sueldo):-
    Sueldo is (5000 * Anios * 1.20).

sueldoTrabajo(periodista(Anios,posgrado),Sueldo):-
    Sueldo is (5000 * Anios * 1.35).

% Agregado del PUNTO VI

sueldoTrabajo(programador(Lenguaje,LineasDeCodigo),Sueldo):-
    esAltoNivel(Lenguaje),
    Sueldo is 10 * LineasDeCodigo.

sueldoTrabajo(programador(Lenguaje,LineasDeCodigo),Sueldo):-
    esBajoNivel(Lenguaje),
    Sueldo is 50 * LineasDeCodigo.

% -----------------------------------------------------------

sueldoTotal(Persona,Sueldo):-
    persona(Persona),
    findall(Cobranza,(trabajo(Persona,Trabajo),sueldoTrabajo(Trabajo,Cobranza)),Cobranzas),
    sumlist(Cobranzas,Sueldo).

% PUNTO VI

% Ver más arriba