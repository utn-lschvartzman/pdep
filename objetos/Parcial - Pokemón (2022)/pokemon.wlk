/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

// Advertencia: Recomiendo mucho leer el DOMINIO DEL PROBLEMA (l.139) para entender el código

class Pokemon {

    const property movimientos = new List()

    const vidaMaxima
    
    var vida

    method grositud() = vidaMaxima * movimientos.sum({m => m.poder()})

    method modificarVida(mod) { vida = (vida + mod).min(vidaMaxima) }

    method movimientosDisponibles() = movimientos.filter({ m => m.estaDisponible()})

    method estaVivo() = vida > 0

    method luchar(pokemon) {

        if(self.estaVivo() && pokemon.estaVivo()){

            const movimientoRandom = self.movimientosDisponibles().anyOne()

            movimientoRandom.utilizar(self, pokemon)
        }
    }
}

class Movimiento {

    var property usos

    method poder()

    method estaDisponible() = usos > 0

    method utilizar(lanzador,receptor) { usos -= 1 }
}

class MovimientoCurativo inherits Movimiento{
    
    const curacion

    override method poder() = curacion

    override method utilizar(lanzador,receptor) {

        super(lanzador,receptor)

        lanzador.modificarVida(curacion)
    }
}

class MovimientoDanino inherits Movimiento{
    
    const dano

    override method poder() = dano * 2

    override method utilizar(lanzador,receptor) {

        super(lanzador,receptor)

        receptor.modificarVida((-dano))
    }
}

class MovimientoEspecial inherits Movimiento{
    
    const property condicion

    override method poder() = condicion.poder()

    override method utilizar(lanzador,receptor) {
        
        condicion.intentarMoverse(lanzador)

        super(lanzador,receptor)

        receptor.condicion(condicion)
    }

}

class CondicionEspecial {

    method puedeMoverse() = 0.randomUpTo(2).roundUp().even()

    method intentarMoverse(pokemon) { if (not self.puedeMoverse()) throw new ExcepcionCondicion(message = "El Pokemón no puede moverse por su condición") }

    method poder()
}

class ExcepcionCondicion inherits DomainException {}

object sueno inherits CondicionEspecial {

    override method poder() = 50

    override method intentarMoverse(pokemon) { super(pokemon) pokemon.condicion(normal) }
}

object paralisis inherits CondicionEspecial {

    override method poder() = 30
}

class Confusion inherits CondicionEspecial {

    const property cantidadTurnos

    override method intentarMoverse(pokemon) { 

        self.consumirTurno(pokemon)

        try { self.intentarMoverse(pokemon) }
        catch e:ExcepcionCondicion { pokemon.modificarVida((-20)) throw new ExcepcionCondicion(message = "El pokemón no pudo moverse y se hizo daño a sí mismo")}

    }

    method consumirTurno(pokemon) {

        if(cantidadTurnos == 0) pokemon.condicion(normal)

        pokemon.condicion(new Confusion(cantidadTurnos = cantidadTurnos - 1)) // No modifico esta instancia, le asigno una nueva (pues es compartida)
    }

    override method poder() = 40 * cantidadTurnos
}

object normal {

    method intentarMoverse(pokemon) {}
}

/*
        DOMINIO DEL PROBLEMA
    
    Cada POKEMON tiene un conjunto de MOVIMIENTOS (que cada uno tiene un efecto particular):

        * MOVIMIENTO CURATIVO: El pokemon que lo usa, se cura en una CONST determinada por el movimiento
            * Cada POKEMON tiene un máximo de vida, debería truncarse
        
        * MOVIMIENTO DAÑINO: El pokemon que lo recibe, se daña en una CONST determinada por el movimiento

        * MOVIMIENTO ESPECIAL: El pokemon que lo recibe, pasa tener una CONDICIÓN ESPECIAL (Parálisis o Sueño)

            * Una condición ESPECIAL puede permitir el movimiento (del pokemon) tirando una moneda.

                * Si la condición es SUEÑO y se le permite el movimiento, su condición pasa a ser NORMAL

                * Si la condición es PARÁLISIS y se le permite el movimiento, su condición seguirá siendo PARALIZADO    
    
    * Cada MOVIMIENTO tiene una cantidad de usos, que se decrementa cada vez que se usa (cuando llega a 0, no se puede usar más)

    Un POKEMON puede luchar solo si está vivo (es decir vida > 0).

    1) Queremos saber la grositud de un pokemón: pokemon.grositud()

        * Se calcula como: vidaMaxima * sumaPoderMovimientos()

            * Los CURATIVOS tienen como poder los puntos que curan
            * Los DAÑINOS tienen como poder el doble del daño que producen
            * Los ESPECIALES tienen: 30 (parálisis) y 50 (sueño)
    
    2) 
        a) Queremos usar el movimiento entre dos pokemones, decrementando un uso y aplicando el efecto correspondiente

        b) Hacer que un pokemón luche contra otro, usando un movimiento de los que tiene disponibles, teniendo en cuenta que
        solo puede moverse si está vivo y su condición se lo permite.

            * Si el pokemón está afectado por una condición, se espera que su turno sea interrumpido
    
    3) Agregar una nueva CONDICIÓN ESPECIAL que sea la CONFUSIÓN, que puede durar una cantidad de turnos determinada, luego de los cuales
    el pokemón se normaliza.

        Si un pokemón CONFUDIDO intenta moverse y no puede, además de no poder luchar, se hace daño a sí mismo por 20 puntos de vida.

        El poder de esta condición es 40 * cantidadTurnos
*/