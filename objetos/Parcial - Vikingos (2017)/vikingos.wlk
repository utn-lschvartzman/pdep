/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

// En las últimas líneas de código hay un texto que explica el dominio del problema, esencial para poder resolverlo.

class Vikingo {

    var property castaSocial

    var cantidadAsesinatos = 0

    var cantidadMonedas = 0

    method esProductivo()

    method castaLoPermite() = if(castaSocial.castaLoPermite(self)) true else throw new ExcepcionCasta(message = "La casta social del vikingo no permite que se suba")

    method recibirPorcion(porcion) {cantidadMonedas += porcion}

    method realizoAsesinato() {cantidadAsesinatos += 1}

    method ascenderSocialmente() { castaSocial.ascender() }

    method recompensar()
}

class Soldado inherits Vikingo {

    var cantidadDeArmas

    method tieneArmas() = cantidadDeArmas > 0

    override method esProductivo() = self.tieneArmas() > 0 && cantidadAsesinatos > 20

    override method recompensar() {cantidadDeArmas += 10}
}

class Granjero inherits Vikingo {

    var cantidadHectareas

    var cantidadHijos

    override method esProductivo() = (cantidadHectareas / 2) >= cantidadHijos

    override method recompensar() {
        cantidadHectareas += 2
        cantidadHijos += 2
    }

}

class CastaSocial {

    method castaLoPermite(vikingo) = true

    method ascender(vikingo) {}

}

object jarl inherits CastaSocial {

    override method castaLoPermite(vikingo) = vikingo.tieneArmas()

    override method ascender(vikingo) {
        vikingo.castaSocial(karl)
        vikingo.recompensar()
    }
}

object karl inherits CastaSocial {

    override method ascender(vikingo) {vikingo.castaSocial(thrall)}
}

object thrall inherits CastaSocial {

    override method ascender(vikingo) {throw new ExcepcionCasta(message = "No se puede ascender desde la casta Thrall, ya es el máximo.")}
}

class Expedicion {
    
    const property integrantes = new List()

    const property invasiones = new List()

    method puedeSubir(vikingo) = vikingo.esProductivo() && vikingo.castaLoPermite()

    method subir(vikingo) {if(self.puedeSubir(vikingo)) integrantes.add(vikingo)}

    method valeLaPena() = invasiones.all{invasion => invasion.valeLaPenaPara(self)}

    method cantidadVikingos() = invasiones.size()

    method invadir() {
        
        invasiones.forEach({invasion => invasion.serInvadida(self)}) // Producir el efecto sobre las aldeas/capitales.

        const porcionPorVikingo = self.botinObtenido() / self.cantidadVikingos() // La cantidad del botín que le corresponde a c/vikingo.

        integrantes.forEach({vikingo => vikingo.recibirPorcion(porcionPorVikingo)}) // Repartir el botín.
    
    }

    method botinObtenido() = invasiones.sum({invasion => invasion.botin()})

    method cobrarVidas() =  integrantes.forEach({vikingo => vikingo.realizoAsesinato()})
}

class Invasion {

    method botin()

    method valeLaPenaPara(expedicion)

    method serInvadida(expedicion)
}

class Capital inherits Invasion {
    
    var cantidadDeDefensores

    const factorDeRiqueza

    override method botin() = cantidadDeDefensores * factorDeRiqueza

    override method valeLaPenaPara(expedicion) = (self.botin() / expedicion.cantidadVikingos()) >= 3

    override method serInvadida(expedicion){

        expedicion.cobrarVidas()

        cantidadDeDefensores -= 0.max(cantidadDeDefensores - expedicion.cantidadVikingos())
    }
}

class Aldea inherits Invasion {

    var cantidadDeCrucifijos

    override method botin() = cantidadDeCrucifijos

    override method valeLaPenaPara(expedicion) = self.botin() >= 15

    override method serInvadida(expedicion) { cantidadDeCrucifijos = 0 }

}

class AldeaAmurallada inherits Aldea {

    const minimoInvasores

    override method valeLaPenaPara(expedicion) = super(expedicion) && expedicion.cantidadVikingos() >= minimoInvasores

}

class ExcepcionCasta inherits DomainException{}

/*
    4) Aparecen los castillos, que son un nuevo posible objetivo a invadir además de las aldeas y capitales. ¿Pueden agregarse sin modificar código existente? 
    Explicar cómo agregarlo. Justificar conceptualmente.

    Es sencillo, pues la idea de un lugar "invadido" ya está contemplado en una clase invasión, la cual es abstracta, pero denota lo que caracteriza (a simples rasgos)
    a cada uno de esos lugares que en efecto, pueden ser invadidos.

    Sería tan sencillo como crear una subclase Castillo que herede de Invasion y overridear los métodos respecto a la lógica del castillo, es decir, cómo se calcula
    su botín y qué le pasa al ser invadido.
*/


/*
        Dominio del problema

Están los vikingos que pueden ser de diferentes castas sociales:

* Jarl, Karl y Thrall (de menor a mayor)

Luego, los vikingos pueden o ser SOLDADOS o GRANJEROS (de cualquier casta)

Para que un vikingo pueda SUBIR a una expedicion, debe ser PRODUCTIVO.

* Un soldado es PRODUCTIVO si tiene 20 kills y tiene armas.

* Un granjero es PRODUCTIVO depende de la cant. de hijos y la cant. de hectáreas designadas p/ alimentarlos (mínimo, 2 c/u)

Además, solo a los vikingos JARL se les prohibe subir con armas (sin cumplen el requisito)

Una expedición vale la pena si todas sus aldeas y capitales valen la pena.

* Invadir una capital VALE LA PENA si en su botin hay al menos tres monedas de oro por c/vikingo de la expedicion

    * El botin es: Monedas de ORO = Cant. de defensores derrotados (potenciado o disminuido por un factor de riqueza de la capital)

    * Invadir una capital, implica que minimo c/vikingo se hace una kill (de defensor)

* Invadir una aldea VALE LA PENA si sacia la sed de saqueo (15 o más monedas en c/aldea)

    * El botin es: Monedas de ORO = Cant. crucifijos en iglesias (que luego serán robados)

    * Las aldeas pueden ser amuralladas, lo que le agrega al "VALE LA PENA" que tiene que haber una cant. mínima de vikingos en la comitiva

Finalmente, los soldados pueden ascender socialmente en la escala Jarl -> Karl -> Thrall

* De Jarl -> Karl: Gana 10 armas (si es soldado) o 2 hectáreas y 2 hijos (si es granjero)

* Karl -> Thrall: Solamente se convierten


3) Realizar una expedición (con efecto, agregando el botin a c/vikingo, y afectando a las aldeas o capitales)

4) Explicar cómo agregaría un castillo, para ser invadido en las expediciones

5) Permitir que un vikingo ascenda socialmente

*/
