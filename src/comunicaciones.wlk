/** First Wollok example */
object empresa {
	const clientes = []
	
	var property precioMinuto = 25

	var property precioMb = 10

	method clientesQueSeComunicaronCon(receptor) = 
		clientes.filter{cli=>cli.seComunicoCon(receptor)}
	
	method agregarCliente(cliente) {
		clientes.add(cliente) 
	}
	
	method todasLasAplicaciones() =
		["wasap","tlgram","icq"]
	
	method liquidacion(mes) = 
		clientes.sum{cli=>cli.liquidacion(mes)}
}

class Cliente {
	const comunicaciones = []
	var property pais = argentina
	
	method comunicacionSoloAmigos() = 
		comunicaciones.all{comu=>comu.suReceptorEsAmigoDe(self)}
	
	method aplicacionMasDatos() =  
	   empresa.todasLasAplicaciones().max{
	   		app => self.datosConsumidosPor(app)
	   }
	
	method datosConsumidosPor(app) =
		comunicaciones.sum{comu=>comu.datosConsumidosPor(app)}
		
	method seComunicoCon(cliente) = 
		comunicaciones.any{comu=>comu.receptor() == cliente}
		
	method mensajear(cliente,mb, app, mes) {
		comunicaciones.add( new Mensaje(
			receptor = cliente,
			datos = mb,
			aplicacion = app,
			mes = mes
		) )
	}
	method llamar(cliente,duracion, mes) {
		comunicaciones.add( new Llamada(
			receptor = cliente,
			minutos= duracion,
			mes = mes
		) )
	}
		
	method incremento() = pais.valorIncremento()
	
	method comunicacionesDelMes(mes) =
		comunicaciones.filter{comu=>comu.mes() == mes}
}

class ClienteBasico inherits Cliente {
	method liquidacion(mes) = 
		self.comunicacionesDelMes(mes)
			.sum{comu=>comu.importe()}
}

class ClienteFull inherits Cliente {
	method liquidacion(mes) = 5000
}

class ClienteControl inherits Cliente {
	var precio
	method liquidacion(mes) =
		self.comunicacionesALiquidar(mes)
			.sum{comu=>comu.importe()} + precio
	
	method comunicacionesALiquidar(mes) = 
		self.comunicacionesDelMes(mes).drop(100)
}

class ClienteTarjetas inherits Cliente {
	const tarjetas = []
	method comprarTarjeta(t){
		tarjetas.add(t)
	}
	method liquidacion(mes) = 
		tarjetas
			.filter{t=>t.mes() == mes}
			.sum{t=>t.precio()} 
}

class Tarjeta {
	var property precio
	var property mes
}

class Pais {
	var property valorIncremento
}

const argentina = new Pais(valorIncremento = 0)

class Comunicacion {
	var property receptor
	var property mes

	method suReceptorEsAmigoDe(cliente) =
		receptor.seComunicoCon(cliente)
}


class Llamada inherits Comunicacion{
	var minutos
	
	method datosConsumidosPor(app) = 0
	
	method importe() = minutos * 
		(empresa.precioMinuto() * (1 + receptor.incremento())) 
}

class Mensaje inherits Comunicacion{
	var datos
	var aplicacion
	
	method datosConsumidosPor(app) =
		if( aplicacion == app) datos else 0
	
	method importe() = datos * empresa.precioMb()
}
