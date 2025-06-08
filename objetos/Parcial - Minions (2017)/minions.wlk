/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

/*
        DOMINIO DEL PROBLEMA

    Tenemos EMPLEADOS (Clase) que pueden ser de dos razas CICLOPES o BICLOPES

        * Los BICLOPES son útiles para todas las tareas, pero su estamina está limitada a 10

        * Los CICLOPES aciertan la mitad de los disparos, no tienen un limite de estamina

        Cada EMPLEADO tiene un ROL que puede cambiar (COMPOSICIÓN), los posibles son: soldados, obrero y mucama.

            * Los SOLDADOS tienen un arma. Cada vez que defiende un sector, gana práctica con el arma (+2 daño).
                * Si cambia de rol, pierde la práctica con el arma.
            
            * Los OBREROS tienen un cinturón con varias herramientas (distintas entre obreros)

            * Las MUCAMAS NO defienden sectores

        El científico (objeto?) puede pedirle a un EMPLEADO que realizarTarea(tarea), que pueden ser:

            SI NO PUEDE REALIZAR LA TAREA SE ESPERA UNA EXCEPCIÓN

            * Arreglar una máquina: C/Máquina tiene una complejidad (const) y un conjunto de herramientas necesarias.

                * Se puede realizar la tarea si la estamina del EMPLEADO = complejidad y tiene todas las herramientas

                * Trabajar implica que el empleado pierda de estamina la complejidad. La dificultad es = 2*complejidad

            * Defender un sector: Requiere que el empleado NO sea mucama y su fuerza sea mayor o igual al grado de amenaza (const)

                * La fuerza de un empleado es: estamina + 2 y:

                    Para los soldados se les suma el daño extra por práctica

                    Para los ciclopes es la mitad
            
                * Trabajar implica perder la mitad de la estamina (si son soldados no pierden nada)

                * La dificultad es: grado de amenaza (biclopes) y grado de amenaza * 2 (ciclopes)
            
            * Limpiar un sector: Se requiere tener para c/sector:

                    * GRANDE: 4 estamina - OTHERWISE: 1 estamina

                * La dificultad es 10 (dado por el científico) (debería ser modificable)

                * Trabajar implica perder la estamina requerida (las mucamas no pierden nada)

    Para recuperar la estamina perdida, los empleados pueden comer fruta. Las bananas recuperan 10 puntos, las manzanas 5 y las uvas 1.

    1) Que un empleado pueda comer una fruta

    2) Conocer la experiencia del empleado = cant tareas realizadas * sum (dificultad tarea)

    3) Hacer que un empleado realice una tarea

    4) Agregar un nuevo rol CAPATAZ que cuando se le pide que haga una tarea, se la delega a su subordinado
    más experimentado de los que puedan realizar la tarea. Si no hay ninguno, debe hacerla él.
*/

class Empleado {

    var property estamina

    method estamina() = estamina

    method modificarEstamina(modificacion) { estamina += modificacion}

    var property rol

    const property tareasRealizadas = new List()

    method comer(fruta) { self.modificarEstamina(fruta.estaminaOtorgada()) }

    method tieneHerramienta(herramienta) = rol.tieneHerramienta(herramienta)

    method fuerza() = 2 + estamina + rol.adicionalFuerza()

    method puedeDefender() = rol.puedeDefender()

    method esInmune() = rol.esInmune()

    method sabeLimpiar() = rol.sabeLimpiar()

    method experiencia() = tareasRealizadas.size() + tareasRealizadas.sum({t => t.dificultad(self)})

    method realizarTarea(tarea) { rol.realizarTarea(self,tarea) }

    method agregarTarea(tarea) { tareasRealizadas.add(tarea) }
}

class Biclope inherits Empleado {

    override method modificarEstamina(modificacion) { estamina += (estamina + modificacion).min(10) }
}

class Ciclope inherits Empleado {

    override method fuerza() = super() / 2

    method esCiclope() = true
}

class Rol {

    method tieneHerramienta(herramienta) = false

    method puedeDefender() = true

    method adicionalFuerza() = 0

    method esInmune() = false

    method sabeLimpiar() = false

    method realizarTarea(empleado,tarea) { 

        if (not tarea.puedeSerRealizada(empleado)) throw new ExcepcionTarea(message = "La tarea no puede ser realizada.")

        empleado.modificarEstamina((-tarea.costoEstamina())) // Gastarse la energía que cuesta hacer la tarea

        empleado.agregarTarea(tarea) // Agregamos la tarea
    }
}

class Soldado inherits Rol {

    const property arma

    var experiencia

    override method adicionalFuerza() = experiencia

    override method esInmune() = true
}

class Obrero inherits Rol {

    const property cinturonDeHerramientas = new List()

    override method tieneHerramienta(herramienta) = cinturonDeHerramientas.contains(herramienta)
}

class Mucama inherits Rol {

    override method puedeDefender() = false

    override method sabeLimpiar() = true
}

class Capataz inherits Rol {

    const subordinados = new List()

    override method realizarTarea(empleado,tarea) {
        
        const subordinadosCapaces = subordinados.filter({s => tarea.puedeSerRealizada(s)})

        if (not subordinadosCapaces.isEmpty()) subordinadosCapaces.max({s => s.experiencia()}).realizarTarea(tarea)

        else super(empleado,tarea)
    }
}

class Tarea {

    method puedeSerRealizada(empleado)

    method dificultad(empleado)

    method costoEstamina(empleado)
}

class ArreglarMaquina inherits Tarea {

    const complejidad

    const herramientasNecesarias

    override method puedeSerRealizada(empleado) = empleado.estamina() >= complejidad && herramientasNecesarias.all({h => empleado.tieneHerramienta(h)})

    override method dificultad(empleado) = complejidad * 2

    override method costoEstamina(empleado) = empleado.estamina() / 2
}

class DefenderSector inherits Tarea {

    const gradoAmenaza

    override method puedeSerRealizada(empleado) = empleado.puedeDefender() && empleado.fuerza() >= gradoAmenaza

    override method costoEstamina(empleado) = if (not empleado.esInmune()) (empleado.estamina() / 2) else 0

    override method dificultad(empleado) = if (empleado.esCiclope()) (gradoAmenaza * 2) else gradoAmenaza
}

class LimpiarSector inherits Tarea {

    const property tipoSector

    override method puedeSerRealizada(empleado) = empleado.estamina() >= tipoSector.estaminaRequerida()

    override method dificultad(empleado) = cientifico.dificultadLimpieza()

    override method costoEstamina(empleado) = if (empleado.sabeLimpiar()) 0 else tipoSector.estaminaRequerida()
}

object grande { method estaminaRequerida() = 4 }

object otro { method estaminaRequerida() = 1 }

object banana { method estaminaOtorgada() = 10 }

object manzana { method estaminaOtorgada() = 5 }

object uva { method estaminaOtorgada() = 1 }

object cientifico { var property dificultadLimpieza = 10 }

class ExcepcionTarea inherits DomainException {}