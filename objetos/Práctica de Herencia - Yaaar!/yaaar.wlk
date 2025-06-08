/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

// BARCOS PIRATAS:

class BarcoPirata {

    const property tripulacion = new Set() // Asumo que no quiero piratas repetidos (?
    
    const property capacidad

    var property mision

    method cantidadTripulantes() = tripulacion.size()

    method tripulacionPasadaDeGrog() = tripulacion.all({pirata => pirata.pasadoDeGrog()})

    method esTemible() = self.puedeRealizarMision() && tripulacion.count{pirata => pirata.esUtil(mision)} >= 5

    method puedeRealizarMision() = self.cantidadTripulantes() > capacidad * 0.9 && mision.cumpleCondiciones(self)

    method esVulnerable(barco) = capacidad < barco.capacidad() * 0.5

    method puedeSerSaqueadoPor(pirata) = pirata.pasadoDeGrog()

    method puedeFormarParte(pirata) = self.quedaEspacio() && mision.esUtil(pirata)

    method quedaEspacio() = capacidad > self.cantidadTripulantes()

    method incorporar(pirata){ 
        if(self.puedeFormarParte(pirata)) tripulacion.add(pirata)
        else self.error("El pirata no puede ser incorporado a la tripulación")
    }

    method cambiarMision(nuevaMision){
        mision = nuevaMision // Acá va a pasar el garbage collector
        tripulacion.removeAllSuchThat({pirata => not mision.esUtil(pirata)})
    }

    method itemMasRaro() = self.itemsBarco().min({item => self.cantidadPiratasConItem(item)})

    method cantidadPiratasConItem(item) = tripulacion.count({pirata => pirata.tieneItem(item)})

    method itemsBarco() = tripulacion.flatMap({pirata => pirata.items()}) // No sé si agregarle un toSet() para ahorrar iteraciones

    method tripulanteMasEbrio() = tripulacion.max({pirata => pirata.nivelEbriedad()})

    method anclarEnCiudad(ciudadCostera){

        tripulacion.forEach({pirata => pirata.tomarGrog(ciudadCostera)})
        
        const tripulanteMasEbrio = self.tripulanteMasEbrio()
        
        tripulacion.remove(tripulanteMasEbrio)
        
        ciudadCostera.incorporar(tripulanteMasEbrio)
    }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

// MISIONES:

class Mision {

    method esUtil(pirata) // Debe ser OVERRIDEADO por su subclase

    method cumpleCondiciones(barco) // Debe ser OVERRIDEADO por su subclase

}

class BusquedaDelTesoro inherits Mision {

    override method esUtil(pirata) = pirata.tieneItemUtil() && pirata.cantidadMonedas() <= 5

    method tieneItemUtil(pirata) = [brujula,mapa,botellaDeGrogXD].any({item => pirata.tieneItem(item)})

    override method cumpleCondiciones(barco) = barco.tripulacion().any({pirata => pirata.tieneItem(llaveDeCofre)})
}

class ConvertirseEnLeyenda inherits Mision {

    const itemObligatorio

    override method esUtil(pirata) = pirata.cantidadItems() >= 10 && pirata.tieneItem(itemObligatorio)

    override method cumpleCondiciones(barco) = true
}

class Saqueo inherits Mision {
    const cantidadMonedas

    const victima

    override method esUtil(pirata) = pirata.cantidadMonedas() < cantidadMonedas && pirata.seAnimaASaquear(victima)

    override method cumpleCondiciones(barco) = victima.esVulnerable(barco)
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

// PIRATAS:

class Pirata {

    const property items = new List()

    var property nivelEbriedad

    var property cantidadMonedas

    method tieneItem(item) = items.contains(item)

    method cantidadItems() = items.size()

    method pasadoDeGrog() = self.nivelEbriedad() >= 90 && self.tieneItem(botellaDeGrogXD)

    method seAnimaASaquear(objetivo) = objetivo.puedeSerSaqueadoPor(self)

    method tomarGrog(ciudad) {
        const precioGrog = ciudad.precioGrog()
        if(cantidadMonedas > precioGrog){
            nivelEbriedad += 5
            cantidadMonedas -= precioGrog
        }
        // Si no lo puede pagar, no hace nada
    }  
    
}

class EspiaDeLaCorona inherits Pirata {

    override method pasadoDeGrog() = false

    override method seAnimaASaquear(objetivo) = super(objetivo) && self.tieneItem(permisoDeLaCorona)

}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

// CIUDADES COSTERAS:

class CiudadCostera {

    var property cantidadHabitantes

    const property precioGrog

    method puedeSerSaqueadoPor(pirata) = pirata.nivelEbriedad() >= 50

    method esVulnerable(barco) = barco.cantidadTripulantes() >= cantidadHabitantes * 0.4 || barco.tripulacionPasadaDeGrog()

    method incorporar(pirata){ cantidadHabitantes+=1 } 


}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

// ITEMS:

const mapa = "Mapa"
const brujula = "Brújula"
const loro = "Loro"
const cuchillo = "Cuchillo"
const botellaDeGrogXD = "Botella de GrogXD"
const llaveDeCofre = "Llave de Cofre"
const permisoDeLaCorona = "Permiso de la Corona"

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


