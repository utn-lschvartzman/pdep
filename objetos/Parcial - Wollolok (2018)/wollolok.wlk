/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

// Sinceramente, no entendí este parcial.

class Jugador {

    const property recursosJugador = new List()

    const property equipo = new List()

    const property edificios = new List()

    method explotar(fuenteRecursos) {

        const recursoExplotacion = fuenteRecursos.recursoDisponible()

        const cantidadRecurso = fuenteRecursos.cantidadDisponible()

        self.gastar(50,oro) // Gasta 50 de oro

        self.recolectar(cantidadRecurso,recursoExplotacion) // Recolecta lo "Explotado"

        fuenteRecursos.someterExplotacion() // La fuente de recursos sufre las consecuencias
    }

    method tieneRecurso(cantidad,recurso) = recurso.cantidadDisponible() >= cantidad

    method gastar(cantidad,recurso) { 
        
        const recursoBuscado = recursosJugador.find({recurso => recurso == recurso})

        if (not self.tieneRecurso(cantidad, recursoBuscado) ) throw new ExcepcionRecurso( message = "No se puede gastar esa cantidad")

        recursoBuscado.modificarCantidad(-cantidad) }

    method recolectar(cantidad,recurso) { recursosJugador.find({recurso => recurso == recurso}).modificarCantidad(cantidad) }

    method rendirse() {
        
        // Reparte sus recursos de forma equitativa con el equipo
        const tamanoEquipo = equipo.size()

        equipo.forEach({ miembro => recursosJugador.forEach({ recurso => miembro.recolectar(recurso.cantidadDisponible() / tamanoEquipo , recurso)}) } )

        self.destruirEdificios()
    }

    method destruirEdificios() { edificios.forEach({ edificio => edificio.destruir() }) }

    method seQuedoSinRecursos() { recursosJugador.all({ recurso => recurso.cantidad() == 0 }) }

    method cantidadEdificiosConstruidos() = edificios.size()

    method edificiosConvenientes() = edificios.filter({ edificio => edificio.convieneAtacar() })

    method edificiosConvertibles() = edificios.filter({ edificio => edificio.puedeSerConvertido() })

    method puedeConstruir(edificio) = edificio.recursosRequeridos().all({recurso => self.tieneRecurso(recurso.cantidadDisponible(),recurso)})

    method construirEdificio(edificio) {

        if (not self.puedeConstruir(edificio)) throw new ExcepcionEdificio(message = "No se pudo construir")

        edificio.recursosRequeridos().forEach({ recurso => recursosJugador.gastar(recurso.cantidadDisponible(), recurso)})
    }
}


class Recurso {

    var property cantidadDisponible

    const resistencia

    method modificarCantidad(modificacion) { cantidadDisponible += modificacion }

    method resistenciaAportada(cantidad) = resistencia * cantidad
}

class oro inherits Recurso {

    override method resistenciaAportada(cantidad) = if (cantidad > 5000) super(cantidad) * 2 else super (cantidad)
}

object madera {}

object comida {}

object piedra {}

class FuenteDeRecursos {

    method recursoDisponible() 

    method cantidadDisponible() = self.recursoDisponible().cantidadDisponible()

    method someterExplotacion() {}
}

class Mina inherits FuenteDeRecursos {

    const property recursoMina

    override method recursoDisponible() = recursoMina
}

object bosque inherits FuenteDeRecursos {

    var quedanArboles = true

    override method recursoDisponible() = madera

    override method cantidadDisponible() = if (quedanArboles) 200 else 0

    override method someterExplotacion() { quedanArboles = not quedanArboles}
}

class Equipo {

    const property miembros = new List()

    method fueDerrotado() = miembros.all({ miembro => miembro.seQuedoSinRecursos() })

    method cantidadEdificiosConstruidos() = miembros.sum({ miembro => miembro.cantidadEdificiosConstruidos()})

    method edificioConveniente() = miembros.map({miembro => miembro.edificiosConvenientes()}).anyOne()

    method edificioConvertible() = miembros.map({miembro => miembro.edificiosConvertibles()}).anyOne()
}

class Edificio {
    
    var property dano = 0

    var property dueno = new Jugador()

    var property estado = normal

    method recursosRequeridos() = new List()

    method estaEnBuenEstado() = self.resistencia() >= self.resistenciaMaxima() * 0.5

    method resistencia() = self.resistenciaMaxima() - dano

    method sumaResistencias() = self.recursosRequeridos().sum({recurso => recurso.resistenciaAportada(recurso.cantidad())})

    method convieneAtacar() = not self.estaEnBuenEstado()

    method activarPoder(equipo) { if (self.estaDestruido()) throw new ExcepcionEdificio(message = "No se puede activar un edificio destruido") }

    method recibirDano(impacto) { dano += impacto }

    method resistenciaMaxima() = estado.resistenciaMaxima(self)

    method puedeSerConvertido() = estado.puedeSerConvertido()

    method convertir(jugador) { dueno = jugador }

    method estaDestruido() = estado.estaDestruido()

    method atacar(edificio,impacto) { 
        
        edificio.recibirDano(impacto) 
        
        if (edificio.resistencia() == 0) edificio.estado(destruido)
    }

    method reparar(cantidad) { dano = (dano - cantidad).max(0) }

    method aplicarMejora(mejora) {

        // El dueño debe gastar el 150% de los recursos requeridos
        if (not self.puedeSerMejorado()) throw new ExcepcionEdificio(message = "No se puede mejorar")

        self.recursosRequeridos().forEach({recurso => dueno.gastar(recurso.cantidadDisponible() * 1.5, recurso)})

        self.estado(mejorado)

        self.reparar(dano)
    }

    method puedeSerMejorado() = estado.puedeSerMejorado()
}

class Estado {

    method resistenciaMaxima(edificio)

    method estaDestruido() = false

    method puedeSerConvertido() = not self.estaDestruido()

    method puedeSerMejorado() = not self.estaDestruido()
}

object destruido inherits Estado {

    override method resistenciaMaxima(edificio) = 0

    override method estaDestruido() = true
}

object normal inherits Estado {

    override method resistenciaMaxima(edificio) = edificio.sumaResistencias()
}

class mejorado inherits Estado { 

    override method puedeSerConvertido() = false

    override method puedeSerMejorado() = false
}

object galeriaDeTiro inherits Edificio {

    override method activarPoder(equipo) {
        
        super(equipo)

        const edificioTarget = equipo.edificioConveniente()

        const danoBase = 100

        const danoARealizar = if (edificioTarget.estaEnBuenEstado()) danoBase else 3 * danoBase

        self.atacar(edificioTarget, danoARealizar)
    }

}

object fuerte inherits Edificio {

    override method activarPoder(equipo) {
        
        super(equipo)

        const edificioTarget = equipo.edificioConveniente()

        if(edificioTarget.estaEnBuenEstado()) dueno.recolectar(500, comida)
        else self.reparar(20)

        self.atacar(edificioTarget, 50)
    }
}

object templo inherits Edificio {

    override method activarPoder(equipo) {

        super(equipo)

        const edificioTarget = equipo.edificioConvertible()

        edificioTarget.convertir(self.dueno())
    }

    override method puedeSerConvertido() = false
}

class ExcepcionEdificio inherits DomainException {}
class ExcepcionRecurso inherits DomainException {}