//
//  CTaxi.swift
//  Xtaxi
//
//  Created by Done Santana on 23/1/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import GoogleMaps
class CTaxi{
    var idTaxi: String
    var matricula :String
    var codTaxi :String
    var marcaVehiculo :String
    var colorVehiculo :String
    var taximarker: GMSMarker
    var idConductor :String
    var nombreApellido :String
    var movil :String
    var urlFoto :String
    
   // var conductor : CConductor
    
    init(){
        self.idTaxi = ""
        self.matricula = ""
        self.codTaxi = ""
        self.marcaVehiculo = ""
        self.colorVehiculo = ""
        //self.conductor = CConductor()
        taximarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        
        self.idConductor = ""
        self.nombreApellido = ""
        self.movil = ""
        self.urlFoto = ""
    }
    init(IdTaxi: String, Matricula :String, CodTaxi :String, MarcaVehiculo :String,ColorVehiculo :String,lat: String, long: String, Conductor : CConductor){
        self.idTaxi = IdTaxi
        self.matricula = Matricula
        self.codTaxi = CodTaxi
        self.marcaVehiculo = MarcaVehiculo
        self.colorVehiculo = ColorVehiculo
        //self.conductor = Conductor
        taximarker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!))
        taximarker.title = idTaxi
        taximarker.icon = UIImage(named: "taxi_libre")
        
        self.idConductor = Conductor.idConductor
        self.nombreApellido = Conductor.nombreApellido
        self.movil = Conductor.movil
        self.urlFoto = Conductor.urlFoto
    }

}