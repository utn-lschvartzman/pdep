/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

class Plato {

    const property cocinero = zipzaper

    const caloriasBase = 100

    method cantidadAzucar()

    method esBonito()

    method calorias() = 3 * self.cantidadAzucar() + caloriasBase
}

object entrada inherits Plato {

    override method cantidadAzucar() = 0

    override method esBonito() = true
}

class Principal inherits Plato {

    const gramosDeAzucar

    const esBonito

    override method cantidadAzucar() = gramosDeAzucar

    override method esBonito() = esBonito   
}

class Postre inherits Plato {

    const cantidadColores

    override method cantidadAzucar() = 120

    override method esBonito() = cantidadColores > 3       
}

class Cocinero {

    var property especialidad

    method catar(plato) = especialidad.catar(plato)

    method cocinar() = especialidad.cocinar()
}

class Especialidad { /* Abstract */

    method catar(plato)

    method cocinar()
}

class Pastelero inherits Especialidad {

    var dulzorDeseado

    method dulzorDesado(set) { dulzorDeseado = set.min(10) } // Como máximo debe ser 10

    override method catar(plato) = 5 * plato.cantidadAzucar() / dulzorDeseado

    override method cocinar() = new Postre(cantidadColores = (dulzorDeseado / 50))
}

class Chef inherits Especialidad {

    const minimoCalorias

    method cumpleExpectativa(plato) = plato.esBonito() && plato.calorias() >= minimoCalorias

    override method catar(plato) = if (self.cumpleExpectativa(plato)) 10 else 0

    override method cocinar() = new Principal(gramosDeAzucar = minimoCalorias, esBonito = true)
}

class Souschef inherits Chef {

    override method catar(plato) = if (not self.cumpleExpectativa(plato)) (plato.calorias() / 100).min(6) else super(plato)

    override method cocinar() = entrada
}

class Torneo { 
    
    const property catadores = new List()

    const property platosPresentados = new List()

    method participar(cocinero) { platosPresentados.add(cocinero.cocinar()) }

    method ganador() {

        if (platosPresentados.isEmpty()) self.error("No se puede presentar un ganador")

        return platosPresentados.max({ plato => self.totalPuntuaciones(plato)}).cocinero()
    }

    method totalPuntuaciones(plato) = catadores.sum({ catador => catador.catar(plato) })
}

object zipzaper {}