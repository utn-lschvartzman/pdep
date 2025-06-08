/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

class Personaje {

    var copas

    method destreza()

    method tieneEstrategia() = false

    method modificarCopas(modificacion) {copas += modificacion}
    
}

class Arquero inherits Personaje {
    
    const rango

    const agilidad

    override method destreza() = rango * agilidad

    override method tieneEstrategia() = rango > 100
}

class Guerrera inherits Personaje {
    
    const tieneEstrategia

    const fuerza

    override method destreza() = fuerza * 1.5

    override method tieneEstrategia() = tieneEstrategia
}

class Ballestero inherits Arquero {
    
    override method destreza() = super() * 2
}

class Mision {

    var property tipoMision = comun

    method copasEnJuego(p)

    method copas(p) = tipoMision.modificarCopas(self.copasEnJuego(p))

    method puedeSerSuperada(p)

    method puedeComenzar(p)

    method realizar(p) { if (not self.puedeComenzar(p)) throw new ExcepcionMision(message = "Misión no puede comenzar") }

    method cantidadPersonajes(p)
}

class Boost {

    const multiplicador

    method modificarCopas(mision) = mision.copasEnJuego() * multiplicador
}

object comun {

    method modificarCopas(mision) = mision.copasEnJuego()
}

object bonus {

    method modificarCopas(mision) = mision.copasEnJuego() + mision.cantidadPersonajes()
}

class MisionIndividual inherits Mision {

    override method cantidadPersonajes(_) = 1

    const property dificultad

    override method copasEnJuego(_) = dificultad * 2

    override method puedeSerSuperada(personaje) = personaje.tieneEstrategia() || personaje.destreza() > dificultad

    override method puedeComenzar(personaje) = personaje.copas() > 10

    override method realizar(personaje){

        super(personaje)

        if (self.puedeSerSuperada(personaje)) personaje.modificarCopas(self.copasEnJuego(personaje))

        else personaje.modificarCopas( - self.copasEnJuego(personaje))
    }

}

class MisionPorEquipo inherits Mision {

    override method copasEnJuego(personajes) = 50 / self.cantidadPersonajes(personajes)

    override method cantidadPersonajes (personajes) = personajes.size()

    override method puedeSerSuperada(personajes) = personajes.count({p => p.tieneEstrategia()}) > (personajes.size() / 2) || personajes.all({p => p.destreza() > 400})

    override method puedeComenzar(personajes) = personajes.sum({p => p.copas()}) >= 60

    override method realizar(personajes) {

        super(personajes)

        if (self.puedeSerSuperada(personajes)) personajes.forEach({p => p.modificarCopas(self.copasEnJuego(personajes))})

        else personajes.forEach({p => p.modificarCopas( - self.copasEnJuego(personajes))})
    }
}

class ExcepcionMision inherits DomainException {}