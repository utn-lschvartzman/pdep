/*
══════════════════════════════════════════════════════════════════
                       RESOLUCIÓN DE PARCIAL

                   Autor: Lucas Schvartzman (2024)

  ADVERTENCIA: Esta resolución fue realizada con fines prácticos.
              Puede contener errores o ser mejorada.
══════════════════════════════════════════════════════════════════
*/

/*

De los MENSAJES sabemos qué usuario los envió y cuantos kb pesa.

    * El peso se calcula como: 5 (datos fijos de transferencia) + contenido.peso() * 1,3 (factor de red)

Un mensaje puede ser de UN contenido, entre ellos:

    * Texto: Sirven para enviar texto, su peso es de 1 kb por caracter

    * Audio: Su peso depende de la duración del mismo. El peso por segundo es 1.2 kb

    * Imagen: De las imagenes conocemos su alto y ancho. La cantidad de pixeles es = alto * ancho

    El peso de una imagen depende del modo de compresión:

        * Compresión original: Se envían todos

        * Compresión variable: Se elige un porcentaje de compresión y se trunca

        * Compresión máxima: Se envía hasta un máximo de 10.000 pixeles, si no se reduce al maximo.

    * GIF: Son como las imágenes pero también tiene una cantidad de cuadros.

    El peso de un GIF es el de una imagen normal de mismas características multiplicada por la cantidad de cuadros.

    Un pixel en GIF o IMAGEN pesan 2KB.

    * Contacto: Se debe saber el usuario que se envía, siempre pesa 3kb

De los CHATS conocemos los participantes.

    Para que un usuario mande un mensaje a un chat, debe pertenecer al chat.

    Cada vez que se envía un mensaje, los usuarios tienen una memoria que se va llenando.

    Antes de mandar un mensaje a un chat, se debe verificar que todos los participantes puedan almacenarlo.

Los CHATS pueden ser PREMIUM, que tienen una restricción adicional:

    * Difusión: Solo el creador puede enviar mensajes

    * Restringido: Hay un limite de mensajes que puede tener el chat

    * Ahorro: Todos los integrantes pueden enviar mensajes de un peso máximo

Las restricciones adicionales y los participantes PUEDEN SER MODIFICADOS en cualquier momento.

1) chat.espacioOcupado() -> Suma de todos los pesos de los mensajes enviados

2) usuario.enviarMensaje(mensaje,chat) -> Considerando todo lo de chats

3) usuario.busquedaTexto()

    Se debe buscar en todos los chats del usuario un mensaje que tenga ese texto:

        * Un mensaje si contiene al texto
        * Un mensaje si es parte del texto de quien lo envia
        * Un mensaje si es parte del nombre del contacto enviado

4) usuario.mensajesMasPesados()

    De cada uno de sus chats, su mensaje más pesado

5) a) Al enviar un mensaje, hacer que cada participante recibaNotificacion(chat)

5) b) Cuando un usuario lee un chat, todas sus notificaciones de ese chat, se eliminan

*/

// MENSAJES

class Mensaje {

    const property usuarioEmisor

    const property contenido

    method peso() = 5 + contenido.peso() * 1.3

    method tieneTexto(texto) = usuarioEmisor.contains(texto) || contenido.tieneTexto(texto)

}

class Contenido {

    method peso() // En KB

    method tieneTexto(texto) = false
}

class Texto inherits Contenido {

    const texto = new String()

    override method peso() = texto.length()

    override method tieneTexto(textoBuscado) = texto.contains(textoBuscado)
}

class Audio inherits Contenido {

    const duracion

    override method peso() = duracion * 1.2
}

class Imagen inherits Contenido {

    const property alto // En píxeles

    const property ancho // En píxeles

    var property modoCompresion

    override method peso() = modoCompresion.pixelesComprimidos(alto,ancho) * 2 // Pesa 2KB cada pixel
}

class ModoCompresion { /* Abstract */

    method pixelesComprimidos(alto,ancho) // En KB
}

object original inherits ModoCompresion {

    override method pixelesComprimidos(alto,ancho) = alto * ancho
}

class Variable inherits ModoCompresion {

    const porcentajePreservacion

    override method pixelesComprimidos(alto,ancho) = alto * ancho * porcentajePreservacion
}

object maximo inherits ModoCompresion {

    const pixelesMaximos = 10000

    override method pixelesComprimidos(alto,ancho) = if ((alto * ancho) > pixelesMaximos) pixelesMaximos else (alto * ancho)
}

class Contacto inherits Contenido {

    const property contacto

    override method peso() = 3 // Un contacto siempre pesa 3KB

    override method tieneTexto(texto) = contacto.contains(texto)
}

// CHATS

class Usuario {

    const property chats = new List()

    const property notificaciones = new List()

    const memoriaDisponible

    method memoriaUtilizada() = chats.sum({ chat => chat.espacioOcupado() })

    method puedeAlmacenar(mensaje) = memoriaDisponible + self.memoriaUtilizada() >= mensaje.peso()

    method enviarMensaje(mensaje,chat) { chat.recibirMensaje(mensaje, self) }

    method busquedaTexto(texto) = chats.filter({ chat => chat.tieneTexto() })

    method mensajesMasPesados() = chats.map({ chat => chat.mensajeMasPesado(self)})

    method recibirNotificacion(notificacion,chat) { notificaciones.add(notificacion) }

    method leer(chat) { notificaciones.removeAllSuchThat({ notificacion => notificacion.chat() == chat })}

}

class Chat {

    const property creador

    const property participantes = new List()

    const property mensajesEnviados = new List()

    method espacioOcupado() = mensajesEnviados.sum({ mensaje => mensaje.peso() })

    method participantesPuedenAlmacenar(mensaje) = participantes.all({ participante => participante.puedeAlmacenar(mensaje)})

    method puedeEnviar(usuario,mensaje) = participantes.contains(usuario) && self.participantesPuedenAlmacenar(mensaje)

    method recibirMensaje(mensaje,usuario) {

        if (not self.puedeEnviar(usuario, mensaje)) self.error("El mensaje no puede enviarse a este chat")

        mensajesEnviados.add(mensaje)

        self.notificarUsuarios(usuario)
    }

    method tieneTexto(texto) = mensajesEnviados.count({ mensaje => mensaje.tieneTexto(texto) }) > 0

    method mensajeMasPesado(usuario) {
        
        const mensajesUsuario = mensajesEnviados.filter({ mensaje => (mensaje.usuarioEmisor() == usuario) })

        return mensajesUsuario.max({ mensaje => mensaje.peso() })
    }

    method notificarUsuarios(usuario) {

        // Esto para no notificar al usuario que envía un mensaje en un chat
        const usuariosNotificados = participantes.filter({ participante => participante != usuario })

        usuariosNotificados.forEach({ usuario => usuario.recibirNotificacion(self,new Notificacion(chat = self))} )
    }
    
}

class Difusion inherits Chat {

    override method puedeEnviar(usuario,mensaje) = super(usuario,mensaje) && (usuario == creador)
}

class Restringido inherits Chat {

    const limiteMensajes

    override method puedeEnviar(usuario,mensaje) = super(usuario,mensaje) && (mensajesEnviados.size() + 1 < limiteMensajes)
}

class Ahorro inherits Chat {

    const limitePeso

    override method puedeEnviar(usuario,mensaje) = super(usuario,mensaje) && mensaje.peso() <= limitePeso
}

class Notificacion { const property chat }