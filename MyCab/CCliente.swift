//
//  CCliente.swift
//  Xtaxi
//
//  Created by Done Santana on 14/10/15.
//  Copyright © 2015 Done Santana. All rights reserved.
//

import Foundation
import GoogleMaps

class CCliente{
    var idUsuario: String!
    var idCliente: String!
    var user : String!
    var nombreApellidos : String!
    var email: String!
    //var origenCarrera: GMSMarker
   // var destinoCarrera: GMSMarker
    //let file = "login.txt"
    //var idUsuario : String
    
    //Constructor
    init(){
        self.idCliente = ""
        self.user = ""
        self.nombreApellidos = ""
        self.email = ""
    }
    init(idUsuario: String, idcliente: String, user: String, nombre: String, email: String){
        self.idUsuario = idUsuario
        self.idCliente = idcliente
        self.user = user
        self.nombreApellidos = nombre
        self.email = email
        
        /*self.idCliente = ""
        //self.idUsuario = ""
        self.user = ""
        self.nombreApellidos = ""
       /* self.origenCarrera = GMSMarker(position: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        self.origenCarrera.icon = UIImage(named: "origen")
        self.destinoCarrera = GMSMarker(position: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        self.destinoCarrera.icon = UIImage(named: "destino")*/
        */
    }
    func AgregarDatosCliente(idUsuario: String,idcliente: String, user: String, nombre: String, email: String){
        self.idCliente = idcliente
        self.idUsuario = idUsuario
        self.user = user
        self.nombreApellidos = nombre
        self.email = email
    }
    
    
    
    /*func CrearSesion(user : String, password: String){
         //this is the file. we will write to and read from it
        let login = user + "," + password
        let path = NSHomeDirectory() + "/Library/Caches/login.txt"
        do {
             _ = try login.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        } catch _ as NSError {
            
        }
    }
    
    func IniciarSesion()->String{
        var login : String!
        let path = NSHomeDirectory() + "/Library/Caches/login.txt"
        do {
            login = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch _ as NSError {
            
        }
        return login
    }
    
    func CerrarSesion(){
        let login = ""
        let path = NSHomeDirectory() + "/Library/Caches/login.txt"
        do {
            _ = try login.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        } catch _ as NSError {
            
        }
    }
    func SesionIniciada()->Bool{
        var login : String!
        let path = NSHomeDirectory() + "/Library/Caches/login.txt"
        do {
            login = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch _ as NSError {
            
        }
        return login == ""
    }*/

}
