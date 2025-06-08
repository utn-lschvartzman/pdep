/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

// Recomiendo muchísimo leer el dominio del problema (l.224) porque el contexto del ejercicio es muy grande y hay mil cosas a tener en cuenta.

class Vikingo {

    const property peso

    const property inteligencia

    const property velocidad

    const property barbarosidad

    const property item

    var nivelDeHambre // En %

    method modificarHambre(modificacion) {nivelDeHambre = 0.max(nivelDeHambre + modificacion)}

    method puedeCargar() = peso * 0.5 + barbarosidad * 2

    method dano() = barbarosidad + item.danoAdicional()

    method puedeParticipar(posta) = nivelDeHambre + posta.hambreProducido() < 100

    method tieneItem(itemBuscado) {itemBuscado == item}
    
    method puedeMontar(dragon) = dragon.puedeSerMontado(self)

    method obtenerJinete(dragon) = if (not self.puedeMontar(dragon)) throw new ExcepcionJinete(message = "No se pudo montar al dragón") else new Jinete(vikingo = self, dragon = dragon)

    method comoLeConvieneParticipar(posta,dragones) {

        const jinetes = dragones.filter({d => self.puedeMontar(d)}).map({d => self.obtenerJinete(d)}) // Para asegurarme que no tira excepción

        return ([self] + jinetes).max({p1,p2 => posta.esMejor(p1,p2)})
    }

}

// Patapez debería ser un objeto, sin embargo, Wollok no permite declarar objetos que heredan de clases sin inicializar todos los métodos y property's
class patapez inherits Vikingo {

    override method puedeParticipar(posta) = nivelDeHambre + posta.hambreProducido() < 50

    override method modificarHambre(modificacion) {

        nivelDeHambre = 0.max(nivelDeHambre + 2 * modificacion)

        item.alimentar(self) // Luego de participar, debe comer 
    }
}

class Item {

    method danoAdicional() = 0
}

class Arma inherits Item {

    const danoAdicional

    override method danoAdicional() = danoAdicional
}

class Alimento inherits Item {

    const hambreDisminuido

    method alimentar(vikingo) = vikingo.modificarHambre(-hambreDisminuido)
}

class Posta {

    method esMejor(competidor,otroCompetidor) = false

    method hambreProducido() = 0

    method jugarPosta(vikingos,dragones) {

        self.inscribir(vikingos,dragones)

        self.registrarResultados(vikingos)

        vikingos.forEach({vikingo => vikingo.modificarHambre(self.hambreProducido())})
    }
    
    var property participantes = new List()

    var property resultados = new List()

    method registrarResultados(vikingos) { resultados = vikingos.sortBy({v1,v2 => self.esMejor(v1,v2)}) }

    method inscribir(vikingos,dragones) { participantes = vikingos.filter({v => v.puedeParticipar(self)}).map({v => v.comoLeConvieneParticipar(self, dragones)}) }

}

object pesca inherits Posta {

    override method esMejor(competidor,otroCompetidor) = competidor.puedeCargar() > otroCompetidor.puedeCargar()

    override method hambreProducido() = 5
}

object combate inherits Posta {

    override method esMejor(competidor,otroCompetidor) = competidor.dano() > otroCompetidor.dano()

    override method hambreProducido() = 10
}

class Carrera inherits Posta {

    const kilometros

    override method esMejor(competidor,otroCompetidor) = competidor.velocidad() > otroCompetidor.velocidad()

    override method hambreProducido() = kilometros
}

object torneo {

    const property vikingos = new List()

    const property postas = new List()

    const property dragones = new List()

    method jugarTorneo() { postas.forEach({posta => posta.jugarPosta(vikingos,dragones)}) }


}

class Dragon {

    const property peso = 100

    const property inteligencia = 50

    method velocidadBase() = 60

    method velocidad() = self.velocidadBase() - peso

    method danoProducido() = 100

    const property requisitos = [requisitoBase]

    method puedeCargar() = peso * 0.2

    method puedeSerMontado(vikingo) = requisitos.all({requisito => requisito.seCumple(self, vikingo)})

}

class FuriaNocturna inherits Dragon {

    const danoProducido

    override method velocidad() = super() * 3

    override method danoProducido() = danoProducido
}

object nadderMortifero inherits Dragon {

    override method danoProducido() = 150
}

object gronckle inherits Dragon {

    override method velocidadBase() = super() / 2

    override method danoProducido() = peso * 5
}

class Requisito {

    method seCumple(dragon,vikingo)
}

object requisitoBase inherits Requisito {

    override method seCumple(dragon,vikingo) = vikingo.peso() <= dragon.puedeCargar()
}

class RequisitoBarbarosidad inherits Requisito {

    const minimoBarbarosidad

    override method seCumple(dragon,vikingo) = vikingo.barbarosidad() >= minimoBarbarosidad
}

class RequisitoItem inherits Requisito {

    const itemRequerido

    override method seCumple(dragon,vikingo) = vikingo.tieneItem(itemRequerido)
}

object requisitoInteligencia inherits Requisito {

    override method seCumple(dragon,vikingo) = vikingo.inteligencia() <= dragon.inteligencia()
}

class Jinete {

    const property vikingo

    const property dragon

    var nivelDeHambre = 0

    method puedeCargar() = vikingo.peso() - dragon.puedeCargar()
    
    method dano() = vikingo.dano() + dragon.danoProducido()

    method velocidad() = dragon.velocidad() - vikingo.peso()

    method modificarHambre(modificacion) { nivelDeHambre += 5}
}

class ExcepcionJinete inherits DomainException {}

/*
        DOMINIO DEL PROBLEMA (PARTE I)

    Sabemos que a un torneo se pueden anotar VIKINGOS y participar de las 3 POSTAS existentes.

    De los VIKINGOS, sabemos su peso, su inteligencia, su velocidad, su barbarosidad, su nivel de hambre (en % , 0% = no tiene hambre) y un item.

        * El ITEM podría ser un arma (que produce un daño) u otro tipo de item (que no produce daño)

    Respecto de las POSTAS (se dice al "mejor" entre dos vikingos)

        * Un VIKINGO no puede participar de una posta si su nivel de hambre alcanzaría 100% por participar:

            * vikingo.puedeParticipar(posta) = peso + posta.hambreProducido() < 100

    La PESCA tiene como mejor al competidor que más pescado pueda cargar. Participar en la PESCA sube un 5% de hambre

        * Un vikingo puedeCargar() = peso * 0.5 + barbarosidad * 2
    
    El COMBATE tiene como mejor al competidor que más daño hace. Participar en el COMBATE sube un 10% de hambre

        * Un vikingo daño() = barbarosidad + item.dañoAdicional()
    
    La CARRERA tiene como mejor al más veloz. Participar en la CARRERA produce un 1% por cada KM (Const) recorrido.

    En el torneo, participan los siguientes vikingos:

    Hipo, item: "Sistema de vuelo"
    Astrid, item: "Hacha (+30 daño)"
    Patán, item: "Masa (+100 daño)"

    Patapez: que NO puede participar si su hambre supera el 50% y el posta.hambreProducido() es el doble. Por eso, su item es un 
    alimento que baja su % de hambre en una CONST indicada luego de participar en una posta

    1) posta.esMejor(competidor,otroCompetidor) - En base al criterio de cada posta.

    2) torneo.jugarTorneo() = postas.forEach({p => p.jugarPosta()}) - Cuando se juega una posta, sucede:

        * Para cada vikingo del torneo (lista), si puede participar de la posta, se agrega a los participantes de la posta

        * Se registra el resultado de cada posta, ordenando de mejor a peor los que participaron

        * Los participantes de la posta deberían sufrir los efectos que correspondan por haber competido


        DOMINIO DEL PROBLEMA (PARTE II)
    
    De los dragones, sabemos su peso, daño producido y su velocidad base (suele ser 60km/h). Luego, su velocidad() = velocidadBase - peso. 
    
    Hay diferentes razas

        * Furia nocturna: Son dragones que tienen el triple de la velocidad que uno normal, y su dañoProducido es una const.

        * Nadder mortífero: Produce 150 de daño

        * Gronckle: Su velocidad base es la mitad que la del resto de los dragones, pero producen como daño = 5 * peso

    Para que un dragon pueda ser montado por un vikingo debe cumplir sus requisitos:

        * El requisito base, es que el vikingo pese como máximo el 20% del peso del dragón.
            * Si un VIKINGO puede montar a un dragón, lo llamaremos jinete.
    
        Luego, como requisitos extra tenemos que:

        * Que la barbarosidad de un vikingo supere un mínimo
        * Que el vikingo tenga un item en particular. Chimuelo que es una furia nocturna requiere un "SISTEMA DE VUELO"
        * Los nadder mortíferos tienen otra restricción que es que la inteligencia del vikingo no supere la propia.

    Queremos que los JINETES puedan participar de una posta, sabiendo que:

        * Un jinete puede cargar tantos kilos de pescado como diferencia haya entre el peso del vikingo y lo que puede cargar el dragón.
        * El daño que puede realizar un jinete es la suma del daño del vikingo y de su dragón.
        * La velocidad de un jinete es la velocidad del dragón menos 1 km/h por cada kilo que pese el vikingo.

        * Los jinetes solo incrementan un 5% del hambre independientemente de la posta

    3) vikingo.puedeMontar(dragon) - Si cumple todos sus requisitos

    4) Obtener el jinete resultante entre un vikingo y un dragón, lo cual debería producir un error si no puede montarlo.

        * IMPORTANTE: No hay que producir efectos sobre el vikingo ni el dragón
    
    5) Saber a partir de un conjunto de dragones que un vikingo podría o no montar, cómo le conviene participar en una posta (es decir, como jinete o como vikingo).
        * Sabemos que le conviene si lo convierte en un mejor competidor
    
    6) A la hora de inscribirse a una posta, los vikingos deberían poder elegir si entrar como vikingo o como jinete. En caso de elegir un dragón, se debe descontar
    de la lista de dragones disponibles (no se espera que post-POSTA vuelvan a estar disponibles)

*/