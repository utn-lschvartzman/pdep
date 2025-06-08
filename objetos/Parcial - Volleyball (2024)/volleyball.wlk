/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

// Este fue el parcial que me tomaron, la nota fue 9.

// Hice un análisis del enunciado que dejé comentado a partir de la l.244 por si lo quieren/necesitan leer

/*

Respecto de la resolución, quiero aclarar que me fue complejo implementar un sistema de puntos
que pudiera perdurar incluso si un partido termina o los otros equipos juegan otros partidos.

Para eso está la clase Estadisticas, que guarda para cada equipo, los goles que lleva en un partido.

Estadísticas no conoce al partido, si no que cada partido tiene un set con las estadisticas de sus dos equipos
a través de las cuales, puede conocer los puntos de cada uno (para tomar decisiones).

Seguramente existía un camino más sencillo hacia la resolución pero fue lo que pude hacer tras analizarlo mucho.

Adicionalmente, me enfoqué también en ciertos detalles que estaban fuera de los requerimientos, como el "marcador"
pero todo con fines de hacer el parcial lo más completo posible.

*/

class Jugador {

    const property estatura // En CM

    const property nivelPrecision

    const property nivelPotencia

    var property posicionDeJuego

    const property saques = new List()

    // Requerimiento del PUNTO 2
    method tieneSaquePeligroso() = saques.any({ saque => saque.esPeligroso(self) })

    // Requerimiento del PUNTO 3
    method puedeRematar() = posicionDeJuego.puedeRematar() && estatura >= 160

    method rotar() { posicionDeJuego = posicionDeJuego.siguientePosicion() }

    method lograDominar(saque) = saque.efectividad(self) > 80

    method numeroPosicion() = posicionDeJuego.numeroPosicion()
}

class PosicionDeJuego {

    const property numeroPosicion // Un número del 1 al 6, un identificador

    const property siguientePosicion // Otra "PosicionDeJuego"

    method puedeRematar()
}

class Delantero inherits PosicionDeJuego {

    override method puedeRematar() = true
}

class Zaguero inherits PosicionDeJuego {

    override method puedeRematar() = false
}

// Posiciones que son bien conocidas, son objetos:
object zagueroDerecho inherits Zaguero(numeroPosicion = 1, siguientePosicion = zagueroCentro) {}
object delanteroDerecho inherits Delantero(numeroPosicion = 2, siguientePosicion = zagueroDerecho) {}
object delanteroCentro inherits Delantero(numeroPosicion = 3, siguientePosicion = delanteroDerecho) {}
object delanteroIzquierdo inherits Delantero(numeroPosicion = 4, siguientePosicion = delanteroCentro) {}
object zagueroIzquierdo inherits Zaguero(numeroPosicion = 5, siguientePosicion = delanteroIzquierdo) {}
object zagueroCentro inherits Zaguero(numeroPosicion = 6, siguientePosicion = zagueroIzquierdo) {}

class Saque { // Creo que esto lo convierte en una clase abstracta

    method esPeligroso(jugador)

    method efectividad(jugador)
}

object saqueDeAbajo inherits Saque {

    override method esPeligroso(jugador) = false

    override method efectividad(jugador) = jugador.nivelPrecision() * 5
}

class SaqueDeArriba inherits Saque {

    const estilo

    override method esPeligroso(jugador) = estilo.esPeligroso(jugador)

    override method efectividad(jugador) = estilo.efectividad(jugador)
}

// ESTILOS: Podrían ser SUBCLASES de SaqueDeArriba o directamente SUBCLASES de Saque

// Vi más interesante encapsular la idea de un estilo de "saque de arriba", c/u con su comportamiento
object deTenis {

    method esPeligroso(jugador) = jugador.nivelPrecision() > 10

    method efectividad(jugador) = (jugador.nivelPrecision() / 2 + jugador.nivelPotencia()) * 3
}

class EnSalto {
    
    // Es válido si cada Saque EnSalto es único para cada jugar, se instancia una nueva clase para c/u

    // No estoy seguro si es correcto "efectividadIndividual" pero conocer al jugador implicaría una doble relación que no está buena
    
    const efectividadIndividual

    method esPeligroso(jugador) = true

    method efectividad(jugador) = efectividadIndividual
}

class Partido {

    const property equipos = new Set() // Tendrá solo 2 elementos

    const property estadisticas = new Set() // Tendrá 2 "Estadisticas"

    var equipoQueSaca = equipos.find({ equipo => equipo.haceSaque() }) // Para tener inicialmente un equipo que saca

    var estaEnJuego // Un booleano que sirve para saber si el partido está en juego

    // Requerimiento del PUNTO 5
    method equipoConVentaja() {

        var equipoConVentaja

        // Si hay una diferencia de puntos entre ambos, se define por puntos
        if (self.puntos(equipos.get(0)) != self.puntos(equipos.get(1))) {

            equipoConVentaja = equipos.max({ equipo => self.puntos(equipo)})
        } 
        else {

            if( equipoQueSaca.jugadorEnPosicion(1).tieneSaquePeligroso() ) { equipoConVentaja = equipoQueSaca}
            else { equipos.max({ equipo => equipo.estaturaPromedio()}) }
        }
        return equipoConVentaja.nombreEquipo()
    }

    method equipoQueSaca() = if (not estaEnJuego && self.estadoValido()) "No hay un equipo que saca" else equipoQueSaca.nombreEquipo()
    
    method recibirPunto(equipo) {
        
        if (not self.estadoValido()) throw new ExcepcionPartido (message = "El partido finalizó, no se pueden recibir más puntos")

        if (equipo != equipoQueSaca) { 
            
            equipos.forEach({ equipo => equipo.invertirRol() })

            equipoQueSaca = equipo // El nuevo equipo que saca será ese
        }

        // Si no empezó, el marcador no debería verse afectado, pero sí ocurren cosas
        if ( not self.empezo() ) { 
            
            estaEnJuego = true // Ahora el partido está en juego

            equipo.rol(saque) // Si ganó el punto por el saque, comienza sacando

            equipos.find( { equipo => equipo != equipo }).rol(defensa) // El otro defiende
        }
        else { estadisticas.find({ estadistica => estadistica.equipo() == equipo}).sumarPunto() } // Suma un punto
    }

    method puntos(equipo) = estadisticas.find({ estadistica => estadistica.equipo() == equipo}).puntosActuales()

    method empezo() = equipos.any({ equipo => self.puntos(equipo) != 0 })

    // Devuelve un string que debería ser "El partido va: 1 - 0" por ejemplo
    method marcador() = "El partido va:" + self.puntos(equipos.get(0)) + " - " + self.puntos(equipos.get(1))

    // Terminó siendo más complejo de lo que me hubiera gustado realmente
    method estadoValido() =  not ( self.gano(equipos.get(0),equipos.get(1)) || self.gano(equipos.get(1),equipos.get(0)) )

    // La condición de VICTORIA se da si uno de los dos anota 25 puntos y le lleva 2 puntos de ventaja al otro
    method gano(unEquipo,otroEquipo) = self.puntos(unEquipo) >= 25 && self.puntos(otroEquipo) < (self.puntos(unEquipo) - 2)


}

class Estadisticas {

    const property equipo // Nombre del equipo

    var puntosActuales = 0 // Empiezan teniendo 0

    method puntosActuales() = puntosActuales

    method sumarPunto() { puntosActuales += 1 }
}

class ExcepcionPartido inherits DomainException {}

class Equipo {

    // Me piden saber el equipo con más ventaja en un partido, queda más bonito recibir el nombre
    const property nombreEquipo 

    const property jugadores = new List()

    var property rol // Cada equipo tiene un ROL designado en la cancha

    // Requerimiento del PUNTO 1
    method estaturaPromedio() = (jugadores.sum({ jugador => jugador.estatura() })) / jugadores.size()

    // Requerimiento del PUNTO 4
    method rotar() { jugadores.forEach({ jugador => jugador.rotar() }) }

    // Requerimiento del PUNTO 6
    method anotarPunto(partido) { rol.anotarPunto(partido, self) }

    method invertirRol() { rol.reasignar(self) }

    method haceSaque() = rol.seEncargaDeSacar()

    method jugadorEnPosicion(numeroPosicion) = jugadores.find({ jugador => jugador.numeroPosicion() == numeroPosicion})

}

class Rol {

    method anotarPunto(partido,equipo) { partido.recibirPunto(equipo) }

    method seEncargaDeSacar()

    method reasignar(equipo)
}

object saque inherits Rol {

    override method seEncargaDeSacar() = true

    override method reasignar(equipo) { equipo.rol(defensa) }
}

object defensa inherits Rol {

    override method anotarPunto(partido,equipo) { 
        
        super(partido,equipo)

        equipo.rotar() // Además, debe rotar
    }

    override method seEncargaDeSacar() = false

    override method reasignar(equipo) { equipo.rol(saque) }
}

/*

Análisis del dominio del problema

Se quiere modelar un partido de voley entre dos equipos

Cada EQUIPO tiene 6 jugadores (lista), donde cada uno tiene una POSICIÓN que debe poder rotarse (Composición?)

De cada partido sabemos el estado actual: 
    
    * El marcador (cuantos puntos anotó cada equipo): Podría ser equipo1.puntos() + "-" equipo2.puntos()

    * Mientras el partido ESTA EN JUEGO, sabemos el equipo que saca en ese momento

    Los partidos se juegan a 25 puntos, si ambos llegan a 24-24, se debe extender hasta que la diferencia sea 2

        * Es decir, se juegan si NO SE CUMPLE la condición de victoria


A lo largo de un partido queremos registrar QUÉ EQUIPO anotó un gol:

    * Al inicio, ambos equipos tienen 0 puntos y se juega un primer punto POR EL SAQUE, sin afectar el marcador.

        * Es decir, podría decirse que cuando esto ocurre el PARTIDO ESTÁ EN JUEGO
    
    * Si anota un gol el EQUIPO SACADOR, solamente debe incrementarse en 1 sus puntos

    * Si anota un gol el EQUIPO RECEPTOR, debe sumar un punto y ROTAR a sus jugadores. Además, pasa a ser el equipo SACADOR

        * Y el EX-SACADOR pasa a ser el nuevo RECEPTOR

    * Una vez que un equipo se consagra ganador, ya NO SE PUEDEN ANOTAR MÁS PUNTOS, ni tampoco hay UN EQUIPO SACADOR.

        * Era información solo relevante DURANTE el partido.
    
Las rotaciones se dan de forma horaria. Hay dos tipos de posiciones diferentes:

    * Delantero (con posiciones 2,3,4): Pueden rematar.

    * Zaguero (con posiciones 1,6,5): No pueden rematar, solo defienden.

    Cada POSICIÓN conoce su siguiente posicion (a la que tendría que rotar, si fuese necesario):

    * zaguero derecho: sig = 6
    * delantero derecho: sig = 1
    * delantero centro: sig = 2
    * delantero izquierdo: sig = 3
    * zaguero izquierdo: sig = 4
    * zaguero centro: sig = 5

De los JUGADORES conocemos su estatura, su nivel de precisión y de potencia

Para cada jugador queremos saber qué saques usa y si logra dominarlo:

    * domina(saque) = saque.efectividad(self) > 80

    * esPeligroso(saque) = saque.esPeligroso() && self.domina(saque)

Hay diferentes TÉCNICAS DE SAQUE, que pueden o no SER PELIGROSAS.

    * Saque DE ABAJO: efectividad(jugador) = jugador.precision() * 5 // esPeligrosa() = false

    * Saque DE ARRIBA: 

        * De TENIS: efectividad(jugador) = (jugador.precision() / 2 + jugador.potencia()) * 3

            esPeligroso () = jugador.potencia() > 10

            * En SALTO: efectividad(jugador) = const (indicada para c/jugador )

REQUERIMIENTOS (Puntos de entrada):

1) equipo.alturaPromedio() / Listo

2) jugador.tieneSaquePeligroso()

3) jugador.puedeRematar() // Teniendo en cuenta su posición y si o si, tiene que medir >= 160

4) equipo.rotar()

5) partido.equipoConVentaja()

    // Será el que más puntos tiene en un momento, si no:

    // El equipo que esté SACANDO será el más ventajoso si el jugador en la posición 1 tiene algún saque peligroso

    // Si no, será el que mayor altura promedio tiene

6) equipo.anotarPunto(partido)

// Queremos que un equipo anote un punto en un partido respetando que:

    Suma solo si el partido está en curso, si el partido está terminado, no debería poderse

*/