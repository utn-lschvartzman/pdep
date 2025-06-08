/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% universidad/1: universidad(Universidad)

universidad(utn).

% carrera/2: carrera(Carrera,Universidad)
carrera(sistemas,utn).

% estudia/3: estudia(Persona,Carrera,Universidad)

estudia(lucas,sistemas,utn).

% trabaja/3: trabaja(Persona,Trabajo,Horas)

trabaja(lucas,programador(prolog),8).

% vinculado/2: vinculado(Trabajo,Carrera)

vinculado(programador(_),sistemas).

% PARTE I: Se busca

% PUNTO I

esObrera(Universidad):-
    universidad(Universidad),
    forall((estudia(Estudiante,_,Universidad)),(trabaja(Estudiante,_,_))).

% PUNTO II

haceOtraCosa(Estudiante,_):-
    trabaja(Estudiante,_,_).

haceOtraCosa(Estudiante,Carrera):-
    estudia(Estudiante,OtraCarrera,_),
    Carrera \= OtraCarrera.

esExigente(Carrera,Universidad):-
    carrera(Carrera,Universidad),
    forall((estudia(Estudiante,Carrera,Universidad)),(not(haceOtraCosa(Estudiante,Carrera)))).

% PUNTO III

cantidadTrabajadores(Universidad,Cantidad):-
    universidad(Universidad),
    findall(_,(estudia(Estudiante,_,Universidad),trabaja(Estudiante,_,_)),Trabajadores),
    length(Trabajadores,Cantidad).

cantidadAlumnos(Universidad,Cantidad):-
    universidad(Universidad),
    findall(_,(estudia(_,_,Universidad)),Estudiantes),
    length(Estudiantes,Cantidad).

porcentajeTrabajadores(Universidad,Porcentaje):-
    cantidadAlumnos(Universidad,Total),
    cantidadTrabajadores(Universidad,Trabajadores),
    Porcentaje is (Trabajadores / Total) * 100.

universidadConMasTrabajadores(Universidad):-
    porcentajeTrabajadores(Universidad,Porcentaje),
    forall((porcentajeTrabajadores(OtraUniversidad,SuPorcentaje),Universidad \= OtraUniversidad),(Porcentaje > SuPorcentaje)).

% PUNTO IV

trabajaEnAlgoVinculado(Persona,Carrera):-
    estudia(Persona,Carrera,_),
    trabaja(Persona,Trabajo,_),
    vinculado(Trabajo,Carrera).

% PUNTO V

esDemandada(Carrera):-
    carrera(Carrera,_),
    forall((estudia(Persona,Carrera,_)),trabajaEnAlgoVinculado(Persona,Carrera)).

% PARTE II: Ambiente laboral

% empleoPrivado(Empresa, Rubro).

empleoPrivado(haskellandia,sistemas(inteligenciaArtificial)).

% empleoPublico(Organismo, Dependencia, Rubro).

empleoPublico(prologgers,gobierno,sistemas(basesDeDatos)).
empleoPublico(builders,gobierno,arquitectura(puentes)).

% planSocial(Organizacion).

planSocial(mingwers).

% organizacion(Organizacion,Rubro).

organizacion(mingwers,sistemas(sistemasOperativos)).

% habilitacionProfesional(Carrera,ListaDeRubros).

habilitacionProfesional(utn,[sistemas(sistemasOperativos),sistemas(basesDeDatos),sistemas(inteligenciaArtificial),arquitectura(puentes)]).

% PUNTO Extra: Trabajo creativo

% emprendedor/2: emprendedor(Emprendedor,Plataforma)
% plataforma/2: plataforma(Plataforma,Rubro)

emprendedor(cryptokid,binance).

plataforma(binance,trading(futuros)).
plataforma(binance,trading(market)).
plataforma(binance,arbitraje(p2p)).
plataforma(binance,inversion).

% En este caso cryptokid pertence a una organización "Binance" que tiene diferentes rubros: trading, arbitraje e inversión (que son functores).