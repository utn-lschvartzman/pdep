/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

class Tempano {

    const property peso

    var property tipo

    method seVeAzul() = tipo.seVeAzul(peso)

    method cuantoEnfria() = tipo.cuantoEnfria(peso)

    method esGrande() = peso > 500

    method parteVisible() = peso * 0.15

    method perderPeso() {tipo.perderPeso(self)}
}

object aireado {

    method seVeAzul(tempano) = false

    method cuantoEnfria(tempano) = 0.5

    method perderPeso(tempano) { tempano.peso( tempano.peso() - 1 )}
}

object compacto  {
    
    method seVeAzul(tempano) = tempano.parteVisible() > 100

    method cuantoEnfria(tempano) = tempano.peso() * 0.01

    method perderPeso(tempano) { 

        tempano.peso( tempano.peso() - 1 )

        if (not tempano.esGrande()) tempano.tipo(aireado)
    }
}

class MasaAgua {

    const property tempanosFlotando = new List()

    const temperaturaAmbiente

    method cantidadTempanos() = tempanosFlotando.size()

    method esAtractiva() =  self.cantidadTempanos() > 5 && tempanosFlotando.all({tempano => (tempano.seVeAzul() || tempano.esGrande())})

    method enfriamientoTempanos() = tempanosFlotando.sum({tempano => tempano.cuantoEnfria()})

    method temperatura() = temperaturaAmbiente - self.enfriamientoTempanos()

    method incorporar(tempano) {tempanosFlotando.add(tempano)}

    method puedeNavegar(embarcacion)

    method sufrirNavegacion() {tempanosFlotando.forEach({tempano => tempano.perderPeso()})}

}

class Lago inherits MasaAgua {

    override method puedeNavegar(embarcacion) = self.cantidadTempanos() > 20 && embarcacion.tamanio() < 10
}

class Rio inherits MasaAgua {

    const velocidadBase

    method velocidad() = velocidadBase - self.cantidadTempanos()

    override method temperatura() = super() + self.velocidad()

    override method puedeNavegar(embarcacion) = self.velocidad() < embarcacion.fuerzaMotor()
}

class Glaciar {

    const property desembocadura

    var property masa

    method temperatura() = 1

    method pesoInicialTempano() = (masa / 1000000) * desembocadura.temperatura()

    method desprendimiento() {

        const tempanoGenerado = new Tempano(peso = self.pesoInicialTempano(),tipo=compacto)

        masa -= self.pesoInicialTempano()

        desembocadura.incorporar(tempanoGenerado)
    }

    method incorporar(tempano) { masa += tempano.peso() }
}

class Embarcacion {

    const property tamanio

    const property fuerzaMotor

    method puedeNavegar(entorno) = entorno.puedeNavegar(self)

    method navegar(entorno) {if (not(self.puedeNavegar(entorno))) throw new ExcepcionNavegacion(message = "No se puede navegar en este entorno") else entorno.sufrirNavegacion()}
}

class ExcepcionNavegacion inherits DomainException {}