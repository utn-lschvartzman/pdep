/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

class Comensal {

    var property posicion = "1@1"

    var property criterioElemento = normal

    var property criterioComida = asiNomas

    const property elementosCercanos = new List()

    const property comidasQueComio = new List()

    method pasar(elemento,comensal) {

        if(not self.tieneElemento(elemento)) throw new ExcepcionElemento(message = "La persona no tiene el elemento")

        criterioElemento.entregarBajoCriterio(elemento,self,comensal)
    }

    method dar(elemento,comensal) {

        self.elementosCercanos().remove(elemento)

        comensal.elementosCercanos().add(elemento)
    }

    method primerElemento() = elementosCercanos.head()

    method tieneElemento(elemento) = elementosCercanos.contains(elemento)

    method come(comida) { criterioComida.come(comida) } 

    method estaPipon() = comidasQueComio.any({comida => comida.esPesada()})

    method laPasaBien() = comidasQueComio.size() > 0
}

object osky inherits Comensal {}

object moni inherits Comensal {

    override method laPasaBien() = super() && self.posicion() == "1@1"
}

object facu inherits Comensal {

    override method laPasaBien() = super() && comidasQueComio.any({comida => comida.esCarne()})
}

object vero inherits Comensal {

    override method laPasaBien() = super() && elementosCercanos.size() <= 3
}

class ExcepcionElemento inherits DomainException {}

class CriterioElemento {

    method entregarBajoCriterio(elemento,emisor,receptor) {emisor.dar(elemento,receptor)}
}

object sordo inherits CriterioElemento {

    override method entregarBajoCriterio(elemento,emisor,receptor) {
        
        const primerElemento = emisor.primerElemento()

        emisor.dar(primerElemento,receptor)
    }
}

object fastidioso inherits CriterioElemento {

    override method entregarBajoCriterio(elemento,emisor,receptor) { emisor.elementosCercanos().forEach({elemento => emisor.dar(elemento, receptor)}) }
}

object cambioPosicion inherits CriterioElemento {

    override method entregarBajoCriterio(elemento,emisor,receptor) {
        
        emisor.posicion(receptor.posicion()) // El emisor se posiciona donde está el receptor

        receptor.posicion(emisor.posicion()) // El receptor se posiciona donde está el emisor

        super(elemento,emisor,receptor)
    }
}

object normal inherits CriterioElemento {}

class Comida {

    const property nombre

    const property calorias

    method esCarne() = false

    method esPesada() = calorias > 500
}

class CriterioComida {

    method come(comida)
}

object vegetariano inherits CriterioComida {

    override method come(comida) = not comida.esCarne()
}

object dietetico inherits CriterioComida {

    override method come(comida) = comida.calorias() < oms.caloriasRecomendadas()
}

class Alternado inherits CriterioComida {

    var property acepto = false

    override method come(comida){

        const aceptaComida = acepto

        acepto = not acepto

        return aceptaComida
    }
}

object asiNomas inherits CriterioComida {
    override method come(comida) = true
}

class Combinado inherits CriterioComida {

    const condiciones

    override method come(comida) = condiciones.all({condicion => condicion.esCumplida(comida)})
}

class Condicion { method esCumplida(comida) }

object oms {
    
    var property caloriasRecomendadas = 500

    method caloriasRecomendadas() = caloriasRecomendadas
}

/*

    Punto 5) Indicar donde se utilizaron:

    * Polimorfismo: Tanto en los criterios de elementos como los de comida, además de las comidas y las personas.

    * Herencia: IDEM a polimorfismo

    * Composición: Los criterios usaban composición, pues debían poder ser intercambiados en tiempos de EJECUCIÓN, sin instanciar una nueva clase

*/