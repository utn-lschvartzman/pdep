/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

// Advertencia: Recomiendo mucho leer el DOMINIO DEL PROBLEMA (l.190) para entender el código ya que es bastante complejo

class Operacion {

    var property estado

    const property inmueble

    method comision()

    method estaReservada() = estado.estaReservada()

    method estaDisponible() = estado.estaDisponible()

    method estaConcretada() = not (self.estaDisponible() && self.estaReservada())

    method intentarReservar(cliente)  { estado.intentarReservar(self) }

    method intentarConcretar(cliente) { estado.intentarConcretar(self) }
}

class Alquiler inherits Operacion {

    const property cantidadMeses

    override method comision() = cantidadMeses * (inmueble.valor() / 50000)

}

class Venta inherits Operacion {

    override method comision() = inmobiliaria.porcentajeVenta() * inmueble.valor()

    override method intentarConcretar(cliente) { if (inmueble.puedeVenderse()) super(cliente) }
}

class EstadoOperacion {

    method estaReservada() = false

    method estaDisponible() = false

    method intentarReservar(operacion,cliente) {}

    method intentarConcretar(operacion,cliente) {}
}

object disponible inherits EstadoOperacion {

    override method estaDisponible() = true

    override method intentarReservar(operacion,cliente) { operacion.estado (new Reservada(clienteReserva = cliente)) }

    override method intentarConcretar(operacion,cliente) { operacion.estado(concretada) }
}

object concretada inherits EstadoOperacion {

    override method intentarReservar(operacion,cliente) { throw new ExcepcionOperacion(message = "No se puede reservar un inmueble ya concretado")}

    override method intentarConcretar(operacion,cliente) { throw new ExcepcionOperacion(message = "No se puede concretar un inmueble ya concretado")}
}

class Reservada inherits EstadoOperacion {

    const clienteReserva

    override method estaReservada() = true

    override method intentarConcretar(operacion,cliente) {

        if (not (clienteReserva == cliente)) throw new ExcepcionOperacion(message = "El inmueble está reservado por otro cliente")

        operacion.estado(concretada)
    }
}

class ExcepcionOperacion inherits DomainException {}

class Inmueble {

    const property tamano

    const property cantidadAmbientes

    var property zona

    method valorBase()

    method puedeVenderse() = true

    method valor() = self.valorBase() + zona.plusZona()
}

class Casa inherits Inmueble {

    const valorParticular

    override method valorBase() = valorParticular
}

class Local inherits Casa {

    var property tipo

    override method valorBase() = tipo.valor(self)

    override method puedeVenderse() = false
}

object galpon {

    method valor(inmueble) = inmueble.valor() / 2

}

object localCalle {

    method valor(inmueble) = inmueble.valor() + inmobiliaria.plusLocal()
}

class PH inherits Inmueble {

    override method valorBase() = (tamano * 14000).min(500000)
}

class Departamento inherits Inmueble {

    override method valorBase() = 350000 * cantidadAmbientes
}

class Zona {

    const property plusZona
}

class Empleado {

    const property operacionesPublicadas = new List()

    const property operacionesReservadas = operacionesPublicadas.filter({o => o.estaReservada()})

    const property operacionesConcretadas = operacionesPublicadas.filter({o => o.estaConcretada()})

    method reservar(operacion,cliente) { operacion.intentarReservar(cliente) operacionesReservadas.add(operacion)}

    method concretar(operacion,cliente) { operacion.intentarConcretar(cliente) operacionesConcretadas.add(operacion)}

    method totalComisiones() = self.operacionesConcretadas().sum({o => o.comision()})

    method cantidadOperacionesConcretadas() = self.operacionesConcretadas().size()

    method cantidadOperacionesReservadas() = self.operacionesReservadas().size()

    method operoMismaZona(empleado) = operacionesPublicadas.any { o => empleado.operacionesPublicadas().any { o2 => o.zona() == o2.zona() } } 
    
    method concretoReserva(empleado) = empleado.operacionesReservadas().any({o => self.operacionesConcretadas().contains(o)})
    
    method tieneProblema(empleado) = self.operoMismaZona(empleado) && (self.concretoReserva(empleado) || empleado.concretoReserva(self))
}

object inmobiliaria {

    const property empleados = new List()

    var property porcentajeVenta = 0.015

    method mejorSegun(criterio) = empleados.max({e => e.criterio().ponderacion(e)})

    var property plusLocal = 0
}

object totalComisiones {

    method ponderacion(empleado) = empleado.totalComisiones()
}

object operacionesConcretadas {

    method ponderacion(empleado) = empleado.cantidadOperacionesConcretadas()
}

object operacionesReservadas {

    method ponderacion(empleado) = empleado.cantidadOperacionesReservadas()
}

/*

        DOMINIO DEL PROBLEMA

    De las OPERACIONES, conocemos la comisión (que cobra el EMPLEADO que la concreta).

    Las OPERACIONES pueden ser de dos tipos: ALQUILER o VENTA:

        * De los ALQUILERES sabemos la cantidad de meses (de alquiler) y la comisión se calcula como: cantidadMeses * valorInmueble / 50000

        * De las VENTAS sabemos que hay un porcentaje de venta (decretado por la inmobiliaria, que actualmente es 1.5) y la comisión es: valorInmueble * porcentajeVenta

    De todos los INMUEBLES conocemos el tamaño en m2, la cantidad de ambientes y la operación en la que está publicada.

    El valor de cada inmueble depende de diversos factores:

        * Si es una CASA, tiene un valor particular (const)

        * Los PH tienen como valor = 14.000 * m2 (mínimo 500.000)

        * Los departamentos tienen como valor = 350.000 * cantAmbientes
    
    * Además, todas las propiedades están afectadas por un plus que depende de la zona, esos valores cambian seguido y las zonas pueden actualizarse (composición).

    Un cliente puede pedirle a un empleado RESERVAR o CONCRETAR una operación publicada. Si una propiedad está reservada no puede ser concretada por otro que no sea
    el mismo cliente que la reservó.

    1) Saber la comisión de una operación concretada

    2) Saber cual fue el mejor empleado según diferentes criterios:

        * Mayor total de comisiones de operaciones concretadas

        * Mayor cantidad de operaciones concretadas

        * Mayor cantidad de operaciones reservadas
    
    3) Saber si un empleado va a tener problema con otro, si ambos operaron en la misma zona y alguno de los dos concretó lo que el otro reservó.

    4) Implementar la RESERVA, COMPRA y ALQUILER de una propiedad

    5) Agregar un nuevo tipo de propiedad: LOCAL. El LOCAL es como una CASA, pero su precio se calcula en base al tipo de local:

        * Los galpones salen la mitad de lo que vale la propiedad

        * Los locales a la calle salen un monto fijo más caro que es igual para todos
    
    ! LOS LOCALES NO PUEDEN VENDERSE, solo PUEDEN ALQUILARSE! ! UN LOCAL DEBE PODER CAMBIAR SU TIPO (composición) !

*/