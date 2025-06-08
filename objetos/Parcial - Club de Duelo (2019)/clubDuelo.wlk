/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

// Recomiendo leer el DOMINIO del problema (l.157)

class Hechicero {

    const property coraje

    const property empatia

    const property conocimiento

    var resistencia

    const resistenciaMaxima

    method cuantoImpacta(impacto) = if(impacto > 0) (resistencia + impacto).min(resistenciaMaxima) else (resistencia - impacto).max(0)

    method impactar(impacto) {resistencia += impacto}

    method hechizoMasConveniente(hechizos,contrincante) = hechizos.max({hechizo => hechizo.conveniencia(self,contrincante)})

    var property efectosVigentes = new List()

    method limpiarEfectos() {efectosVigentes = efectosVigentes.filter({efecto => efecto.estaDisponible()})}

    method puedeHechizar() = efectosVigentes.all({efecto => efecto.puedeHechizar()})

    method agregarEfectos(efectos) { efectosVigentes.add(efectos) }

    method finalizarTurno() {

        efectosVigentes.map({efecto => efecto.aplicar(self)}) // Aplicar los efectos al hechicero

        efectosVigentes.forEach({efecto => efecto.pasoTurno()}) // Pasó un turno, para cada efecto

        self.limpiarEfectos() // Elimina los efectos que ya no están disponibles
    }

}

class Caracteristica {

    method nivel(hechicero)
}

object coraje inherits Caracteristica{
    override method nivel(hechicero) = hechicero.coraje()
}

object empatia inherits Caracteristica{
    override method nivel(hechicero) = hechicero.empatia()
}

object conocimiento inherits Caracteristica{
    override method nivel(hechicero) = hechicero.conocimiento()
}

object balance inherits Caracteristica {

    override method nivel(hechicero) = (hechicero.conocimiento() + hechicero.empatia() + hechicero.coraje()) / 3
}

class Hechizo {

    const property caracteristica

    const property potencia

    const property efectos = new List()

    method impactoBase(lanzador,contrincante) = potencia + 2 * (caracteristica.nivel(lanzador) - caracteristica.nivel(contrincante))

    method impacto(lanzador,contrincante)

    method lanzar(lanzador,contrincante) { if(not lanzador.puedeHechizar()) throw new ExcepcionHechizo(message = "El hechicero no puede lanzar hechizos")}

    method conveniencia(lanzador, contrincante) = self.impacto(lanzador, contrincante) + efectos.sum({efecto => efecto.aumentoConveniencia()})
}

class Ataque inherits Hechizo {

    override method impacto(lanzador,contrincante) = contrincante.cuantoImpacta(self.impactoBase(lanzador,contrincante))

    override method lanzar(lanzador,contrincante) { 
        
        super(lanzador,contrincante) // Verifica si el lanzador puede lanzar el hechizo
        
        contrincante.impactar(self.impacto(lanzador,contrincante))
    
        contrincante.agregarEfectos(efectos)
    }

    override method conveniencia(lanzador,contrincante) = if (self.loMata(lanzador,contrincante)) (super(lanzador,contrincante) * 2 ) else super(lanzador,contrincante)
    
    method loMata(lanzador,contrincante) = self.impactoBase(lanzador,contrincante) != self.impacto(lanzador,contrincante)
}

class Cura inherits Hechizo {

    override method impacto(lanzador,contrincante) = lanzador.cuantoImpacta(self.impactoBase(lanzador,contrincante))

    override method lanzar(lanzador,contrincante) { 
        
        super(lanzador,contrincante) // Verifica si el lanzador puede lanzar el hechizo
        
        lanzador.impactar(self.impacto(lanzador,contrincante)) 
        
        lanzador.agregarEfectos(efectos)
    }
}

class EfectoDuradero {

    var property cantidadTurnos

    method aumentoConveniencia() = self.multiplicador() * cantidadTurnos

    method multiplicador()

    method puedeHechizar() = true

    method estaDisponible() = cantidadTurnos > 0

    method aplicar(hechicero) {}

    method pasoTurno() { cantidadTurnos -= 1 }
}

class CuracionDiferida inherits EfectoDuradero {

    const resistenciaQueAumenta

    override method multiplicador() = 2 * resistenciaQueAumenta

    override method aplicar(hechicero) { hechicero.impactar(hechicero.cuantoImpacta(resistenciaQueAumenta)) }
}

class DanoDiferido inherits EfectoDuradero {

    const resistenciaQueDecrementa

    override method multiplicador() = 3 * resistenciaQueDecrementa

    override method aplicar(hechicero) { hechicero.impactar(hechicero.cuantoImpacta(resistenciaQueDecrementa)) }
}

class Aturdimiento inherits EfectoDuradero {
    
    override method puedeHechizar() = false

    override method multiplicador() = 5
}

class ExcepcionHechizo inherits DomainException {}

/*
        DOMINIO DEL PROBLEMA (Parte I)

    En cada turno del duelo, un hechicero lanza un hechizo y si al final de su turno, la resistencia del rival es 0, ganó.

    * Durante el duelo la resistencia debe estar entre 0 y el máximo de resistencia (es una constante).

    De cada hechicero, conocemos sus características: coraje, empatía y conocimiento. 

    De cada hechizo sabemos su potencia, impacto, y qué característica tiene en cuenta (diferencia).

    Los HECHIZOS pueden ser de ATAQUE (afecta al contrincante) o CURATIVOS (afecta al lanzador)

    El impacto en la resistencia del AFECTADO, equivale a = potencia + 2 * (Dif. Característica)

        * Si el impacto es mayor a la resistencia actual del AFECTADO, se acota.
    
    a) Dados dos hechiceros y un hechizo, queremos saber el impacto que tendría en la resistencia del AFECTADO.

    b) Hacer que un hechizo se lance contra un AFECTADO (aplicando el efecto correspondiente)

    c) Dado un conjunto de hechizos y un contrincante, determinar cual es el más conveniente para un hechicero.

        * La conveniencia de un hechizo es el impacto sobre el afectado. Para los de ataque, si el impacto lo mata, se duplica la conveniencia.

    d) Queremos agregar una característica balance, que es el promedio de las otras tres características

        DOMINIO DEL PROBLEMA (Parte II)
    
    Los hechizos pueden tener efectos extra, que se aplican al final de un turno y pueden durar varios turnos. Un hechicero puede estar bajo varios efectos a la vez.

    Para cada efecto DURADERO se indicará por cuantos turnos durará. Los efectos son los siguientes (y también deben tenerse en cuenta para la conveniencia)

        * EFECTO CURACIÓN DIFERIDA: Se indica cuanta resistencia se recupera en c/turno, el aumento de conveniencia es = 2 * resistencia * cant turnos

        * EFECTO DAÑO DIFERIDA: Se indica cuanta resistencia se pierde en c/turno, el aumento de conveniencia es = 3 * resistencia * cant turnos

        * EFECTO ATURDIMIENTO: Un hechciero aturdido no puede lanzar hechizos, el aumento de conveniencia es = 5 * cant turnos 

    a) Agregar los efectos duraderos a la conveniencia

    b) Adaptar la lógica de hechizos para que:

        * Si el hechicero está aturdido, falle al intentar usar un hechizo

        * Como consecuencia de lanzar el hechizo, además debe quedar bajo los efectos duraderos, que se suman a los viejos.

    c) Hacer que un hechicero sufra los efectos al finalizar un turno (decrementando un turno, que si no quedan, no afectan más)
*/