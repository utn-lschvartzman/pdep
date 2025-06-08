{-
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
-}

module Library where
import PdePreludat

----------------------------------------------
-- Código base provisto en el enunciado
----------------------------------------------

---------------------------
--  Modelado de Peleador --
---------------------------

data Peleador = Peleador{
    nombre :: String,
    vida :: Number,
    resistencia :: Number,
    ataques :: [Ataque]
} deriving (Show,Eq)

---------------
--  Punto 1  --
---------------

-- Punto 1.a
estaMuerto :: Peleador -> Bool
estaMuerto = (== 0) . vida

-- Abstracciones del Punto 1.b
esResistente :: Peleador -> Bool
esResistente = (>15) . resistencia

conoceAtaques :: Peleador -> Bool
conoceAtaques = (>=10) . length . ataques

-- Punto 1.b
esHabil :: Peleador -> Bool
esHabil peleador = esResistente peleador && conoceAtaques peleador

-- Abstracciones del Punto 1.c
modificarVida :: (Number -> Number) -> Peleador -> Peleador
modificarVida modificador peleador = peleador {vida = modificador (vida peleador)}

-- Punto 1.c
perderVida :: Number -> Peleador -> Peleador
perderVida cantidad = modificarVida (max 0 . subtract cantidad)

---------------
--  Punto 2  --
---------------

-- Abstracciones del Punto 2.a
conseguirReduccion :: Number -> Peleador -> Number
conseguirReduccion intensidad  = div intensidad . resistencia

type Ataque = Peleador -> Peleador

-- Punto 2.a
golpe :: Number -> Ataque
golpe intensidad peleador = flip perderVida peleador . conseguirReduccion intensidad $ peleador -- Leer abajo

-- Realmente no amo la implementación de las funciones golpe y toqueDeLaMuerte pero tampoco considero que estén mal
-- Por lo tanto quedan así, además, se compensa con funciones de abajo que si quedaron mucho más bonitas

-- Punto 2.b
toqueDeLaMuerte :: Ataque
toqueDeLaMuerte peleador = flip perderVida peleador . vida $ peleador -- Leer arriba

-- Abstracciones del Punto 2.c
type Parte = String

modificarResistencia :: (Number -> Number) -> Peleador -> Peleador
modificarResistencia modificador peleador = peleador {resistencia = modificador (resistencia peleador)}

esPecho :: Parte -> Bool
esPecho = (== "Pecho")

esCarita :: Parte -> Bool
esCarita = (== "Carita")

esNuca :: Parte -> Bool
esNuca = (== "Nuca")

modificarAtaques :: ([Ataque] -> [Ataque]) -> Peleador -> Peleador
modificarAtaques modificador peleador = peleador {ataques = modificador (ataques peleador)}

-- Punto 2.c
-- Siempre disminuye la resistencia en un punto modificarResistencia (subtract 1)
patada :: Parte -> Ataque
patada parteDelCuerpo peleador
    | esPecho parteDelCuerpo && not (estaMuerto peleador) = bajarResistencia . perderVida 10 $ peleador
    | esPecho parteDelCuerpo && estaMuerto peleador = bajarResistencia . modificarVida (+1) $ peleador
    | esCarita parteDelCuerpo = bajarResistencia . modificarVida (*0.5) $ peleador
    | esNuca parteDelCuerpo = bajarResistencia . modificarAtaques (drop 1) $ peleador
    | otherwise = bajarResistencia peleador
        where bajarResistencia = modificarResistencia (subtract 1)

-- Abstracciones del Punto 2.d (que incluso me sirvió para muchos otros puntos :D)
-- Básicamente compone todos los ataques en un único ataque
aplanarAtaques :: [Ataque] -> Ataque
aplanarAtaques = foldr (.) id

-- Punto 2.d
tripleAtaque :: Ataque -> Ataque
tripleAtaque = aplanarAtaques . replicate 3

---------------
--  Punto 3  --
---------------

-- Abstracción para el ataque adicional
cambiarNombre :: String -> Peleador -> Peleador
cambiarNombre nuevoNombre peleador = peleador { nombre = nuevoNombre}

-- Ataque especial inventado por mí
-- El ataque consiste en perder 5 de resistencia, luego 10 de vida y finalmente cambiar tu nombre luego de la verguenza de haber sido golpeado con este ataque
ataqueDeLaVerguenza :: Ataque
ataqueDeLaVerguenza = cambiarNombre "DerrotadiusPeleiadorus" . perderVida 10 . modificarResistencia (subtract 5) 

-- Punto 3: Definición de Bruce Lee
bruceLee :: Peleador
bruceLee = Peleador {nombre = "Bruce Lee", vida = 200, resistencia = 25, ataques = ataquesBruceLee}

ataquesBruceLee :: [Ataque]
ataquesBruceLee = [toqueDeLaMuerte, golpe 500, patada "Nuca", tripleAtaque (patada "Carita"),ataqueDeLaVerguenza]

---------------
--  Punto 4  --
---------------

-- Función dada en el punto 4

f :: Ord a => (b -> a) -> c -> [ c -> b ] -> (c -> b)
f _ _ [x] = x
f g p (x:y:xs) 
    | (g.x) p < (g.y) p = f g p (x : xs)
    | otherwise         = f g p (y : xs)

{-
    Punto 4.a: ¿Qué hace esta función? ... La verdad es una buena pregunta 

    QUÉ HACE:

    La función del punto 4 se encarga de filtrar la lista de funciones (recibida como tercer parámetro) 
    hasta tener una única función de esa lista y retornarla.

    Respecto del filtro:
    A la función le interesa quedarse con la función que aplicada al segundo parámetro, y luego ese resultado aplicado a la función que recibe como
    primer parámetro, dé el MENOR resultado (esta comparación se hace siempre sobre dos funciones de la lista)
-}

-- Sabiendo esto, refactoricemos la función para que sea más EXPRESIVA

-- Abstracción del Punto 4.a
esMenorConFuncion1 :: Ord a => (b -> a) -> c -> [ c -> b ] -> Bool
esMenorConFuncion1 funcion parametro (funcion1Lista: funcion2Lista: resto) = 
    ( funcion . funcion1Lista ) parametro < ( funcion . funcion2Lista) parametro

-- Punto 4.a (Refactoreo)
laQueMenos :: Ord a => (b -> a) -> c -> [ c -> b ] -> (c -> b)
laQueMenos _ _ [laFuncionQueMenos] = laFuncionQueMenos
laQueMenos funcion parametro (funcion1Lista: funcion2Lista: resto)
    | esMenorConFuncion1 funcion parametro (funcion1Lista: funcion2Lista: resto) = eliminarSegundaFuncion
    | otherwise         = eliminarPrimeraFuncion
    where  eliminarSegundaFuncion = laQueMenos funcion parametro (funcion1Lista : resto)
           eliminarPrimeraFuncion = laQueMenos funcion parametro (funcion2Lista : resto)

-- Punto 4.b (utilizando laQueMenos)
mejorAtaque :: Peleador -> Ataque
mejorAtaque peleador = laQueMenos vida peleador (ataques peleador)

---------------
--  Punto 5  --
---------------

-- Abstraccion del Punto 5.a.i
esTerrible :: Ataque -> [Peleador] -> Bool
esTerrible ataque enemigos = mitadAnterior > vivosPostAtaque
    where mitadAnterior = flip div 2 . length . filter (not . estaMuerto) $ enemigos
          vivosPostAtaque = length . filter (not . estaMuerto) . map ataque $ enemigos

-- Punto 5.a.i
ataquesTerribles :: [Peleador] -> Peleador -> [Ataque]
ataquesTerribles enemigos peleador = filter (`esTerrible` enemigos)(ataques peleador)

-- Abstracciones del Punto 5.a.ii
ataqueEsMortal :: Ataque -> Peleador -> Bool
ataqueEsMortal ataque = estaMuerto . ataque

esMortalParaAlguno :: Ataque -> [Peleador] -> Bool
esMortalParaAlguno ataque = any (ataqueEsMortal ataque)

todosLosAtaquesSonMortales :: [Ataque] -> [Peleador] -> Bool
todosLosAtaquesSonMortales ataques enemigos = all (`esMortalParaAlguno` enemigos) ataques

-- Punto 5.a.ii
esPeligroso :: Peleador -> [Peleador] ->  Bool
esPeligroso peleador enemigos = esHabil peleador && todosLosAtaquesSonMortales (ataques peleador) enemigos

-- Abstracción del Punto 5.a.iii
conseguirAtaques :: [Peleador] -> Ataque
conseguirAtaques = aplanarAtaques . take 10 . map mejorAtaque . filter esHabil

-- Punto 5.a.iii
esInvencible :: Peleador -> [Peleador] -> Bool
esInvencible peleador enemigos = vida peleador == vida (conseguirAtaques enemigos peleador) 

-- Punto 5.b

{-

    El punto 5.a tiene tres funciones asi que analicemos cada una (teniendo en cuenta la lista infinita de enemigos)

    - ataquesTerribles: Esta función no puede retornar la lista de ataques terribles ya que hace un filter de "esTerrible" y
    esta función internamente hace esto: length . filter (not . estaMuerto) $ enemigos que realiza un filtrado sobre la lista infinita
    y encima luego consulta si longitud (ambas cosas imposibles en una lista infinita, osea, no tiene valor de retorno ni fin)

    - esPeligroso: Esta función si puede retornar True o False debido a que la única función que opera con la lista infinta
    es "todosLosAtaquesSonMortales" que su vez utiliza "esMortalParaAlguno" que hace un any (de ataqueEsMortal) a la lista
    de enemigos, lo que dará False o True con tan solo analizar la primera ocurrencia (entonces, no necesita evaluarla entera)

    - esInvencible: Esta función no puede retornar True o False por la simple razón de que utiliza "conseguirAtaques", función
    que recibe la lista de enemigos y los filtra por "esHabil" (filtro que nunca terminará si la lista es infinita)

-}