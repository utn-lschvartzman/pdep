/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

% Parcial: Lógico - ¡Pensando en el Bondi! - 04/09/2024

% Recorridos en GBA:
recorrido(17, gba(sur), mitre).
recorrido(24, gba(sur), belgrano).
recorrido(247, gba(sur), onsari).
recorrido(60, gba(norte), maipu).
recorrido(152, gba(norte), olivos).

% Recorridos en CABA:
recorrido(17, caba, santaFe).
recorrido(152, caba, santaFe).
recorrido(10, caba, santaFe).
recorrido(160, caba, medrano).
recorrido(24, caba, corrientes).

% Agrego recorrido para probar el caso de Marta en una línea (de jurisdicción "buenosAires") que pasa por zona norte y oeste únicamente.
% Ver PUNTO V
recorrido(1, gba(norte), haskellLandia).
recorrido(1, gba(oeste), prologLandia).
recorrido(1, gba(norte), cLandia).

% Agrego otra linea para que exista una calle de transbordo

recorrido(2,gba(norte),javaLandia).
recorrido(2,caba,santaFe).

%% RESOLUCIÓN %%

% PUNTO I

% Dos líneas pueden combinarse si su recorrido pasa por la misma calle en la misma zona.
puedenCombinarse(Linea1, Linea2):-
    recorrido(Linea1, Zona, Calle),
    recorrido(Linea2, Zona, Calle),
    Linea1 \= Linea2.

% PUNTO II

% provincia/2: provincia(Zona, Provincia)
% Relaciona la zona con su provincia respectiva (que luego será la jurisdicción)
provincia(caba,caba).
provincia(gba(_),buenosAires).

% Una línea cruza la general paz si tiene recorrido en CABA y en GBA (Cualquier zona).
cruzaLaGeneralPaz(Linea):-
    recorrido(Linea,caba,_),
    recorrido(Linea,gba(_),_).

% Una línea es de jurisdicción nacional si cruza la general paz
jurisdiccion(Linea, nacional):-
    cruzaLaGeneralPaz(Linea). % Como este predicado es inversible, entonces jurisdiccion/2 (en este caso) también.

% Una línea es de la jurisdicción correspondiente a su provincia si NO cruza la general paz
jurisdiccion(Linea, Jurisdiccion):-
    recorrido(Linea,Zona,_),
    provincia(Zona,Jurisdiccion),
    not(cruzaLaGeneralPaz(Linea)).

% PUNTO III

% El transito de una calle en una zona es la cantidad de líneas que tienen un recorrido ahí.
transitoCalle(Calle,Zona,Transito):-
    recorrido(_,Zona,Calle),
    findall(Linea, recorrido(Linea,Zona,Calle), Transitos),
    length(Transitos, Transito).

% La calle más transitada es aquella que comparada con todas las demás (forall/2), tiene un transito mayor.

% Este predicado es totalmente inversible pues tiene sentido por fuera de este punto, no sería raro querer
% saber el tránsito de una calle en una zona.

% Una calle de una zona no es "mas transitada" que el resto si todas tienen el mismo tránsito (de hecho, esto
% sucede con las de GBA SUR y NORTE, cuyo tránsito es siempre 1).

calleMasTransitada(Calle,Zona):-
    transitoCalle(Calle,Zona,Transito),
    forall((transitoCalle(Otra,Zona,OtroTransito), Calle \= Otra),(Transito > OtroTransito)).

% PUNTO IV

% pasaLineaTipo/4: Indica si una línea de un tipo específico de jurisdiccion pasa por una calle en una zona.
pasaLineaTipo(Linea,Jurisdiccion,Calle,Zona):-
    recorrido(Linea,Zona,Calle),
    jurisdiccion(Linea,Jurisdiccion).

% cantidadLineasNacionales/3: Cuenta la cantidad de líneas de jurisdicción nacional que pasan por una calle en una zona

% Me gustaría aclarar que no parametrizo la jurisdicción en este caso porque la abstracción no tiene sentido fuera
% de este predicado (por eso tampoco es inversible).

% La única razón de esta abstracción, es para hacer el código más expresivo y limpio, nada más.

cantidadLineasNacionales(Calle,Zona,Cantidad):-
    findall(Linea,(pasaLineaTipo(Linea,nacional,Calle,Zona)),Lineas),
    length(Lineas,Cantidad).

% Una calle en una zona es considerada de transbordo, si por lo menos 3 líneas nacionales pasan por ella.
calleTransbordo(Calle,Zona):-
    recorrido(_,Zona,Calle),
    cantidadLineasNacionales(Calle,Zona,Cantidad),
    Cantidad >= 3.

% PUNTO V

% PUNTO V - A

% Modelado de BENEFICIARIOS

% tieneBeneficio/2: tieneBeneficio(Persona, Beneficio)

tieneBeneficio(pepito,casasParticulares(gba(oeste))).

tieneBeneficio(juanita,estudiantil).

% Como Tito no tiene ningún beneficio no se agrega a la base de conocimientos, por el principio de universo cerrado.
% El motor Prolog, tomará como falso todo lo que no esté como verdadero en la base.

tieneBeneficio(marta,jubilado).
tieneBeneficio(marta,casasParticulares(caba)).
tieneBeneficio(marta,casasParticulares(gba(sur))).

% casasParticulares(Zona de domicilio laboral).

% Agregado para el PUNTO V - C

/*

    Si se quisiera agregar un nuevo beneficio "discapacidad" sería sencillo pues el predicado tieneBeneficio/2, utiliza
    un functor para encapsular el "beneficio", de esta forma admitiendo POLIMORFISMO, lo que hace que agregar un functor
    nuevo de aridad "n" sea sencillo y no tenga ningún impacto negativo en el código y su estructura ya desarrollada.

    Podria hacerse de la siguiente forma:

    tieneBeneficio(juan,discapacitado(grave)).

    De esta forma el functor discapacitado, también guarda información sobre el nivel de gravedad de la discapacidad,
    por ejemplo, si no pudieras mover tus piernas (grave), se te haría un beneficio total para cualquier línea, pero para una discapacidad
    de grado menor (como que te falten 2 dedos, supongamos), te harían pagar la mitad del boleto.

    Por supuesto que los descuentos/beneficios tienen que ser  aplicados de forma correcta respetando la estructura que el código
    tiene actualmente para "dar los descuentos", pero tampoco sería difícil, gracias al functor utilizado.

    En síntesis, no sería nada muy distinto a lo que ya se hizo para este punto, solo tocaría crear los nuevos predicados y adaptar.

*/

% Respecto del modelado de PERSONAS

% Para este caso puntual SOLAMENTE consideraremos a las personas que TIENEN BENEFICIO. Si no, deberíamos agregar esto:

% persona(tito). Pues Tito en realidad es persona, pero no tiene beneficios.

% persona(Persona):-
%    tieneBeneficio(Persona,_).

% Como no es necesario, hacemos inversible (respecto de las personas) los predicados utilizando tieneBeneficio/2 directamente

linea(Linea):-
    recorrido(Linea,_,_).

% Modelado de BENEFICIOS (en este caso, el precio final aplicado según el tipo de beneficio).

% El boleto ESTUDIANTIL tiene un costo fijo de 50
beneficio(estudiantil,Linea,50):- % Donde dice Línea iba a poner un "_" pero mejor si puede ser inversible
    linea(Linea). % Hace inversible a la línea

% El boleto de JUBILADOS tiene un costo de 50% de descuento al precio base
beneficio(jubilado,Linea,Subsidio):-
    precioLinea(Precio,Linea),
    Subsidio is (Precio /2).

% El boleto de CASAS PARTICULARES se subsidia totalmente si la línea pasa por esa zona
beneficio(casasParticulares(Zona),Linea,0):-
    pasaPorZona(Linea,Zona).

% En este caso, esta cláusula de beneficio no representa beneficio alguno, por ende el precio final es el precio base de la línea.
beneficio(casasParticulares(Zona),Linea,Subsidio):-
    not(pasaPorZona(Linea,Zona)),
    precioLinea(Subsidio,Linea).

pasaPorZona(Linea,Zona):-
    recorrido(Linea,Zona,_).

% PUNTO V - B

% callesQueRecorre/2: Relaciona a una línea con la cantidad de calles que recorre
callesQueRecorre(Linea,Cantidad):-
    linea(Linea),
    findall(Calle,recorrido(Linea,_,Calle),Calles),
    length(Calles,Cantidad).

% Este predicado indica si una línea pasa por al menos 2 diferentes zonas
pasaPorZonasDiferentes(Linea):-
    recorrido(Linea,Zona1,_),
    recorrido(Linea,Zona2,_),
    Zona1 \= Zona2.

% recargoZonas/2: Relaciona una línea con el recargo ($50 o $0) que le corresponde si pasa por diferentes zonas o no

recargoZonas(0,Linea):-
    linea(Linea),
    not(pasaPorZonasDiferentes(Linea)).

recargoZonas(50,Linea):-
    pasaPorZonasDiferentes(Linea).

% precioLinea/2: Relaciona una línea con su precio base correspondiente.

% Como el precio de una línea tiene sentido por fuera de este punto, es TOTALMENTE INVERSIBLE.

% Si es de jurisdicción NACIONAL sale $500
precioLinea(500,Linea):-
    jurisdiccion(Linea,nacional).

% Si es de jurisdicción CABA sale $350
precioLinea(350,Linea):-
    jurisdiccion(Linea,caba).

% Si es de jurisdicción BUENOS AIRES sale ($25 * Cantidad de calles que recorre) + Recargo por zona ($50 o $0)
precioLinea(Precio,Linea):-
    jurisdiccion(Linea,buenosAires),
    callesQueRecorre(Linea,CallesRecorridas),
    recargoZonas(Recargo,Linea),
    Precio is (25 * CallesRecorridas) + Recargo.

% precioBoleto/3: Indica el precio que tendría un boleto para una persona en una línea, considerando sus respectivos beneficios.
% Este predicado da TODAS las posibilidades, por eso en precioFinal/3 se selecciona el mejor precio (el más bajo)

% Es totalmente inversible pues tiene sentido por fuera de este punto.

precioBoleto(Persona,Linea,Precio):-
    tieneBeneficio(Persona,Beneficio),
    beneficio(Beneficio,Linea,Precio).

% Finalmente, llega el predicado que hace lo pedido por el PUNTO V, precioFinal/3: 
% Que relaciona el precio MÁS BAJO que una persona puede pagar por un viaje en una línea (que será el finalmente 
% abonado, pues no son acumlables los descuentos).

% Lo que hace: Para todos los precios de un boleto disponibles para una persona (en función de sus beneficios)
% Se desea obtener el que sea el más bajo.

precioFinal(Persona,Linea,PrecioMasBajo):-
    precioBoleto(Persona,Linea,PrecioMasBajo),
    forall((precioBoleto(Persona,Linea,Precio), PrecioMasBajo \= Precio), (PrecioMasBajo < Precio)).

% PUNTO V - C

% Ver más arriba en este mismo punto

% Pruebas que hice para el PUNTO V

/*
    84 ?- precioFinal(marta,1,Precio).
    Precio = 62.5 .

    La línea 1 que agregue (se puede ver más arriba), cumple con el ejemplo que se da en el enunciado:
    "En cambio, para una línea de jurisdicción buenosAires que pasa por zona norte y oeste únicamente,
    debería abonar la mitad de lo que cueste el viaje normal en esa línea, osea: 
    ($50 + $25 * Cantidad de calles del recorrido) / 2, por el beneficio de jubilada"

    Y efectivamente es así:

    + $50 (Pues la línea 1 pasa por dos zonas distinas GBA NORTE y GBA OESTE)
    + $25 * 3 (Pues la línea 1 recorre 3 calles)

    Lo que da 125 / 2 = 62.5 (Verifica)


    Luego, el boleto para una línea de jurisdicción nacional debería valer gratis:

    84 ?- precioFinal(marta,24,Precio).
    Precio = 0 .

    Lo que tiene sentido pues la línea 24 es de jurisdiccion nacional (pasa por CABA y Marta tiene beneficio ahí)

*/