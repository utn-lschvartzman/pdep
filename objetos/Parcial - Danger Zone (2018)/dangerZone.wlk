/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

class Empleado {
    var property puesto

    const property habilidades = new List() 

    var salud

    var misionesCumplidas

    method estaIncapacitado() = salud < puesto.saludCritica()

    method puedeUsar(habilidad) = not self.estaIncapacitado() && self.tieneHabilidad(habilidad)

    method tieneHabilidad(nombreHabilidad) = habilidades.any({habilidad => habilidad.nombre() == nombreHabilidad})

    method usoHabilidad(nombreHabilidad){
        
        const habilidadUsada = habilidades.find({habilidad => habilidad.nombre() == nombreHabilidad})

        habilidadUsada.incrementarUso()

        misionesCumplidas += 1 // Si usó una habilidad, es porque cumplió una misión
    }

    method aprenderHabilidad(habilidad) = if(not self.tieneHabilidad(habilidad)) habilidades.add(habilidad)

    method herirse(cantidad) { salud -= cantidad}

    method experiencia() = misionesCumplidas + puesto.experienciaPuesto(self)

    method aporteHabilidades() = habilidades.map({habilidad => habilidad.aporte()})
}

object espia {

    method saludCritica() = 15

    method completoMision(mision,empleado){

        const ultimaHabilidad = mision.ultimaHabilidad()

        empleado.aprenderHabilidad(ultimaHabilidad)
    }

    method experienciaPuesto(empleado) = empleado.aporteHabilidades() 

}

class Oficinista {
    var estrellas

    method saludCritica() = 40 - 5 * estrellas

    method completoMision(mision,empleado){

        estrellas += 1

        if(estrellas == 3) empleado.puesto(espia)

    }
    
    method experienciaPuesto(empleado) = estrellas * 2
}

class Habilidad {

    const property nombre

    var property usos = 0

    method incrementarUso() { usos += 1 }
    
    method aporte() = usos + nombre.length() 
}

class Mision {

    const property objetivos

    method habilidadesRequeridas() = objetivos.map({objetivo => objetivo.habilidadRequerida()})

    method objetivosPendientes() = objetivos.map({objetivo => not objetivo.estaCumplido()})

    method estaCompleta() = self.objetivosPendientes().isEmpty()

    method ultimaHabilidad() = self.habilidadesRequeridas().last()
}

class Objetivo {

    const property habilidadRequerida

    const property peligrosidad

    method estaCumplido() = false

    method minimoResolucion() = 3

    method esPeligroso() = peligrosidad > 0

}

class Equipo {

    const property integrantes = new List()

    method reuneHabilidades(mision) = mision.habilidadesRequeridas().all({habilidadRequerida => integrantes.any({integrante => integrante.tieneHabilidad(habilidadRequerida)})})

    method cumplir(mision){

        if(mision.estaCompleta()){
            throw new ExcepcionMisionCompleta(message = "No se puede cumplir una misión que ya está completa")
        }

        mision.objetivosPendientes().forEach({objetivoPendiente => self.resolverObjetivo(objetivoPendiente)})

        self.supervivientes().forEach({empleado => empleado.completoMision()})

    }

    method supervivientes() = integrantes.filter({integrante => integrante.salud() > 0})

    method resolverObjetivo(objetivo){

        const empleadoResponsable = integrantes.findOrElse({empleado => empleado.tieneHabilidad(objetivo.habilidadRequerida())},
        {throw new ExcepcionFaltaHabilidad(message = "No hay empleados con la habilidad requerida.")})

        if(objetivo.esPeligroso()){
            
            if (not integrantes.size() > objetivo.peligrosidad()) throw new ExcepcionFaltanIntegrantes(message = "El objetivo es muy peligroso para el equipo")

            empleadoResponsable.herirse(objetivo.peligrosidad())

        }

        empleadoResponsable.usoHabilidad(objetivo.habilidadRequerida())

        objetivo.estaCumplido(true)
        
    }
}

class Agencia {

    const equipo

    method reputacion() = equipo.supervivientes().sum({integrante => integrante.experiencia()})

    method haceCompetenciaA(agencia) = self != agencia

}

class ExcepcionMisionCompleta inherits DomainException{}
class ExcepcionFaltaHabilidad inherits DomainException{}
class ExcepcionFaltanIntegrantes inherits DomainException{}

/*

    Punto 7:

    Si se quisiera incorporar un nuevo tipo de empleado, en este caso, los científicos no habría ningún
    impacto con la solución actual, pues desde un principio se manejó el tema del puesto laboral a través
    de una simple referencia a la clase/objeto, lo que lo hace extremadamente flexible para agregar los
    puestos que hagan falta.

    Bastaría con declarar una nueva clase/objeto y hacer referencia a ella en la clase empleado, para el
    empleado que sea científico.

*/