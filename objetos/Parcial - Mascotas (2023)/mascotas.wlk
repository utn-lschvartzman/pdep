/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

class Familia {

    const property tamanoCasa

    const property miembros = new List()

    const property mascotas = new List()

    method espacioDisponible() = tamanoCasa - (miembros + mascotas).sum({f => f.espacioOcupado()})

    method tieneLugar(animal) = animal.espacioOcupado() < self.espacioDisponible()

    method puedeAdoptar(animal) = self.tieneLugar(animal) || (miembros + mascotas).all({f => not f.tieneProblema(animal)})

    method tieneMenor() = miembros.any({m => not m.esMayor()})

    method tieneMascota() = not mascotas.isEmpty()

    method adoptar(animal) { mascotas.add(animal) }

}

class Persona {

    const property edad

    const property animalesRechazados = new List()

    method esAlergica()

    method esMayor() = edad > 13

    method espacioOcupado() = if (self.esMayor()) 1 else 0.75

    method tieneProblema(animal) = animalesRechazados.contains(animal) || (self.esAlergica() && animal.esPeludo())

}

class Animal {

    const property nombre

    method espacioOcupado()

    method esPeludo() = false

    method tieneProblema(animal) = false
}

class Gato inherits Animal {

    const property esMalaOnda

    override method espacioOcupado() = 0.5

    override method esPeludo() = true

    override method tieneProblema(animal) = esMalaOnda

}

class Pez inherits Animal {

    override method espacioOcupado() = 0

}

class Perro inherits Animal {

    const property raza

    override method espacioOcupado() = raza.espacioOcupado()

    override method esPeludo() = raza.esPeludo()

    override method tieneProblema(animal) = raza.tieneProblema(animal,self)

}

class PerroSalvaje inherits Perro {

    override method espacioOcupado() = super() * 2

    override method esPeludo() = true
}

class Raza {

    method esPeludo() = false

    method espacioOcupado() = 0.5

    method tieneProblema(animal,perro) = false
}

object razaChica inherits Raza {

    override method tieneProblema(animal,perro) = animal.espacioOcupado() > perro.espacioOcupado()
}

class RazaGrande inherits Raza {

    const espacioOcupado

    override method espacioOcupado() = espacioOcupado

    override method tieneProblema(animal,perro) = animal.espacioOcupado().between(0.5, perro.espacioOcupado() )

}

object razaPeluda inherits Raza {

    override method esPeludo() = true
}

object veterinaria {

    const property familiasRegistradas = new List()

    const property animalesEnAdopcion = new List()

    // Devuelve la cantidad de familias que tienen un menor entre sus integrantes y no tienen mascotas
    method familiasConMenorSinMascotas() = familiasRegistradas.count({f => not (f.tieneMenor() && f.tieneMascota())})
    
    // Devuelve los nombres de los animales que no pueden ser adoptados por ninguna familia (de las registradas)
    method animalesNoAdoptivos() = animalesEnAdopcion.filter({a => familiasRegistradas.all({f => not f.puedeAdoptar(a)})}).map({a => a.nombre()})

    // Devuelve una lista con las familias que pueden adoptar a todos los animales en adopción
    method familiasTotalmenteAdoptivas() = familiasRegistradas.filter({f => animalesEnAdopcion.all({a => f.puedeAdoptar(a)})})

    method darEnAdopcion(animal,familia){
        
        if(not familia.puedeAdoptar(animal)) throw new ExcepcionVeterinaria(message = "No se puede dar en adopción el animal a dicha familia")
        
        animalesEnAdopcion.remove(animal)
        familia.adoptar(animal)    
    }

}

class ExcepcionVeterinaria inherits DomainException {}