/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

class Consumo {

    const fechaConsumo = new Date()

    method costo()

    method esDeMBs() = false

    method estaEntre(fechaInicio,fechaFinal) = fechaConsumo.between(fechaInicio, fechaFinal)

}

class ConsumoMBs inherits Consumo {

    const property cantidadMBs

    override method esDeMBs() = true

    override method costo() = cantidadMBs * pdepfoni.precioPorMB()
}

class ConsumoSegundos inherits Consumo {

    const property cantidadSegundos

    override method costo() = if(cantidadSegundos < 30) pdepfoni.precioFijoLlamadas() else pdepfoni.precioFijoLlamadas() + (cantidadSegundos - 30) * pdepfoni.precioPorSegundo()
}

object pdepfoni {

    var property precioPorSegundo = 0.05

    var property precioPorMB = 0.1

    var property precioFijoLlamadas = 1
}

class LineaTelefonica {

    const property numeroDeTelefono

    const consumos = new List()

    var property deuda

    var property tipoDeLinea

    const packs = new List()

    method agregarPack(pack) = packs.add(pack)
    
    method costosEnRango(fechaInicio,fechaFinal) = consumos.sum({consumo => consumo.estaEntre(fechaInicio, fechaFinal)})

    method costoPromedio(fechaInicio,fechaFinal) = self.costosEnRango(fechaInicio,fechaFinal) / consumos.size()

    method costoTotalMensual() = self.costosEnRango(new Date(),new Date().minusDays(30)) // new Date() = Hoy

    method puedeRealizarConsumo(consumo) = packs.any({pack => pack.puedeSatisfacer(consumo)})

    method realizarConsumo(consumo){

        if(not self.puedeRealizarConsumo(consumo)) tipoDeLinea.manejoConsumo(consumo,self)

        else { 

            const packAConsumir = packs.reverse().find({pack => pack.puedeRealizarConsumo(consumo)})

            packAConsumir.consumir(consumo)

            consumos.add(consumo)

        }
    }

    method limpiarPacks() { packs.removeAllSuchThat({pack => pack.esInservible()})}

    method sumarDeuda(suma) { deuda += suma }

}

class Pack {

    const fechaDeVigencia = 0

    method puedeSatisfacer(consumo) = false

    method esInservible() = self.estaVencido() || self.estaAcabado()

    method estaVencido() = new Date() > fechaDeVigencia

    method estaAcabado() = false

}

class PackConsumible inherits Pack {

    var property cantidadRestante

    method consumir(consumo)

    override method estaAcabado() = cantidadRestante == 0

}

class PackMBLibres inherits PackConsumible {

    const cantidadMBs

    override method consumir(consumo) {cantidadRestante -= consumo.cantidadDeMBs()}

    override method puedeSatisfacer(consumo) = consumo.esDeMBs() && cantidadMBs > consumo.cantidadMBs()
}

class PackCredito inherits PackConsumible {

    const credito

    override method consumir(consumo) {cantidadRestante -= consumo.costo()}

    override method puedeSatisfacer(consumo) = credito > consumo.costo()
}

class PackMBLibresPlusPlus inherits PackMBLibres{

    override method puedeSatisfacer(consumo) = if(not self.estaAcabado()) super(consumo) else cantidadMBs <= 0.1
}

object packLlamadasGratis inherits Pack{

    override method puedeSatisfacer(consumo) = not consumo.esDeMBs()
}

object packInternetIlimitadoFindes inherits Pack {

    override method puedeSatisfacer(consumo) = consumo.esDeMBs() && new Date().isWeekendDay()
}

object normal { method manejoConsumo(consumo,linea) = throw new ExcepcionConsumo(message = "La línea no puede hacer el consumo.") } 

object black { method manejoConsumo(consumo,linea) = linea.sumarDeuda(consumo.costo()) }

object platinum { method manejoConsumo(consumo,linea) = true }

class ExcepcionConsumo inherits DomainException{}

// PUNTO 10

// Tanto para el pack como para el consumo, basta con crear un objeto o clase (según corresponda) y hacerla heredar la superclase correspondiente (Pack,PackConsumible,Consumo)
