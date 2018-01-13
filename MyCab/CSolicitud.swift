//
//  CSolicitud.swift
//  Xtaxi
//
//  Created by Done Santana on 29/1/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import GoogleMaps
import CoreData

class CSolicitud {
    
    var idSolicitud: String
    var origenCarrera: GMSMarker
    var destinoCarrera: GMSMarker
    var referenciaorigen :String //= datos[8];
    var fechaHora : String
    var tarifa : Double
    var distancia : Double
    var tiempo : String
    var costo : String
    
    //Cliente
    var idCliente: String
    var user : String
    var nombreApellidos : String
    
    //Taxi
    var idTaxi: String
    var matricula :String
    var codTaxi :String
    var marcaVehiculo :String
    var colorVehiculo :String
    var taximarker: GMSMarker
    //Conductor
    var idConductor :String
    var nombreApellido :String
    var movil :String
    var urlFoto :String


//Constructor
    init(){
        self.idSolicitud = ""
        self.referenciaorigen = ""
        self.fechaHora = ""
        self.tarifa = 0.0
        self.distancia = 0.0
        self.tiempo = "0"
        self.costo = "0"
        self.origenCarrera = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        self.destinoCarrera = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        
        
        //Cliente
        self.idCliente = ""
        self.user = ""
        self.nombreApellidos = ""
        
       // self.cliente = CCliente()
        //self.taxi = CTaxi()
        
        self.idTaxi = ""
        self.matricula = ""
        self.codTaxi = ""
        self.marcaVehiculo = ""
        self.colorVehiculo = ""
        taximarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        
        self.idConductor = ""
        self.nombreApellido = ""
        self.movil = ""
        self.urlFoto = ""
        
    }
    
    //agregar datos del cliente
    func DatosCliente(cliente: CCliente){
        self.idCliente = cliente.idCliente
        self.user = cliente.user
        self.nombreApellidos = cliente.nombreApellidos
    }
    //Agregar datos del Conductor
    func DatosTaxiConductor(idtaxi :String, matricula: String, codigovehiculo :String, marcaVehiculo:String, colorVehiculo: String,lattaxi :String, lngtaxi :String, idconductor: String, nombreapellidosconductor :String, movilconductor: String, foto: String){
        self.idConductor = idconductor
        self.nombreApellido = nombreapellidosconductor
        self.movil = movilconductor
        self.urlFoto = foto
        self.idTaxi = idtaxi
        self.matricula = matricula
        self.codTaxi = codigovehiculo
        self.marcaVehiculo = marcaVehiculo
        self.colorVehiculo = colorVehiculo
        taximarker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(lattaxi)!, longitude: Double(lngtaxi)!))
        taximarker.icon = UIImage(named: "taxi_libre")
        taximarker.title = idtaxi
    }

    //REGISTRAR FECHA Y HORA
    func RegistrarFechaHora(IdSolicitud: String, FechaHora: String){ //, tarifario: [CTarifa]
        self.idSolicitud = IdSolicitud
        self.fechaHora = FechaHora
    }
    //Agregar datos de la solicitud
    func DatosSolicitud(dirorigen :String, referenciaorigen :String, dirdestino :String, latorigen :String, lngorigen :String, latdestino :String, lngdestino :String,FechaHora: String){
        self.referenciaorigen = referenciaorigen
        self.origenCarrera = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(latorigen)!, longitude: Double(lngorigen)!))
        self.origenCarrera.title = "Origen"
        self.origenCarrera.icon = UIImage(named: "origen")
        self.origenCarrera.snippet = dirorigen
        self.destinoCarrera = GMSMarker(position:CLLocationCoordinate2D(latitude: Double(latdestino)!, longitude: Double(lngdestino)!))
        self.destinoCarrera.title = "Destino"
        self.destinoCarrera.icon = UIImage(named: "destino")
        self.destinoCarrera.snippet = dirdestino
        self.fechaHora = FechaHora
    }
    
    //Dibujar Iconos y Ruta de la Carrera
    func DibujarRutaSolicitud(mapa: GMSMapView){
        if taximarker.position.latitude != 0{
            let origenCoord = String(origenCarrera.position.latitude) + "," + String(origenCarrera.position.longitude)
            let taxiCoord = String(taximarker.position.latitude) + "," + String(taximarker.position.longitude)
            let rutataxi = CRuta(origin: origenCoord, destination: taxiCoord)
            let routePolyline1 = rutataxi.drawRoute()
            let lines1 = GMSPolyline(path: routePolyline1)
            lines1.strokeWidth = 5
            lines1.title = rutataxi.totalDuration
            lines1.map = mapa
            lines1.strokeColor = UIColor.red
        }
    }
    
    func DetallesCarrera(tarifas: [CTarifa])->[String]{
        let origenCoord = String(self.origenCarrera.position.latitude) + "," + String(origenCarrera.position.longitude)
        let destinoCoord = String(destinoCarrera.position.latitude) + "," + String(destinoCarrera.position.longitude)
        let ruta = CRuta(origin: origenCoord, destination: destinoCoord)
        var costo : Double!
        let distancia = ruta.totalDistance
        var temporal = String(self.fechaHora).components(separatedBy: " ")
        temporal = String(temporal[1]).components(separatedBy: ":")
        for var tarifatemporal in tarifas{
            if (Int(tarifatemporal.horaInicio) <= Int(temporal[0])!) && (Int(temporal[0])! <= Int(tarifatemporal.horaFin)){
                if Double(distancia)! <= 3{
                    costo = Double(distancia)! * tarifatemporal.valorKilometro1
                }
                else{
                    if Double(distancia)! <= 10{
                        costo = 3 * tarifatemporal.valorKilometro1 + (Double(distancia)! - 3) * tarifatemporal.valorKilometro2
                    }else{
                        costo = (3 * tarifatemporal.valorKilometro1) + (7 * tarifatemporal.valorKilometro2) + ((Double(distancia)! - 10) * tarifatemporal.valorKilometro3)
                    }

                }
                if costo < tarifatemporal.valorMinimo{
                    costo = tarifatemporal.valorMinimo
                }
                costo = costo + tarifatemporal.valorArranque
            }
        }

        self.distancia = Double(distancia)!
        self.tiempo = ruta.totalDuration
        self.costo = String(costo)
        return [distancia, ruta.totalDuration, String(format:"%.2f",costo)]
    }
    
    func TiempoTaxi()->[String]{
        let origenCoord = String(self.origenCarrera.position.latitude) + "," + String(origenCarrera.position.longitude)
        let taxi = String(taximarker.position.latitude) + "," + String(taximarker.position.longitude)
        let ruta = CRuta(origin: origenCoord, destination: taxi)
        return [ruta.totalDistance,ruta.totalDuration]
    }

}
