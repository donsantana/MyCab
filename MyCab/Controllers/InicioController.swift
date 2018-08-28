//
//  InicioController.swift
//  UnTaxi
//
//  Created by Done Santana on 2/3/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import GoogleMaps
import SocketIO
import Canvas
import AddressBook
import AVFoundation
import CoreData

class InicioController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, GMSMapViewDelegate, UITextFieldDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, UIApplicationDelegate, AVAudioPlayerDelegate {
    var coreLocationManager : CLLocationManager!
    var miposicion = CLLocationCoordinate2D()
    var locationMarker = MKPointAnnotation()
    var taxiLocation : GMSMarker!
    var userAnotacion : GMSMarker!
    var origenAnotacion : GMSMarker!
    var destinoAnotacion : GMSMarker!
    var taxi : CTaxi!
    var login = [String]()
    var idusuario : String = ""
    var indexselect = Int()
    var contador = 0
    var centro = CLLocationCoordinate2D()
    var TelefonosCallCenter = [CTelefono]()
    var opcionAnterior : IndexPath!
    var evaluacion: CEvaluacion!
    var taxiscercanos = [GMSMarker]()
    //var SMSVoz = CSMSVoz()
    
    var responseData = NSMutableData()
    var data: Data!
    var timer = Timer()
    var fechahora: String!
    
    
    var tiempoTemporal = 10
    
    var taximetro: CTaximetro!
    var TaximetroTimer = Timer()
    var TaximetroTotalTimer = Timer()
    var espera = 0
    
    

    //variables de interfaz
    
    @IBOutlet weak var origenIcono: UIImageView!
    @IBOutlet weak var mapaVista : GMSMapView!

    
    @IBOutlet weak var origenText: UITextView!
    @IBOutlet weak var referenciaText: UITextView!

 

    @IBOutlet weak var LocationBtn: UIButton!
    @IBOutlet weak var SolicitarBtn: UIButton!
    @IBOutlet weak var formularioSolicitud: UIView!
    
    @IBOutlet weak var EnviarSolBtn: UIButton!

    
    //MENU BUTTONS
    @IBOutlet weak var MenuView: UIView!
    @IBOutlet weak var CallCEnterBtn: UIButton!
    @IBOutlet weak var SolPendientesBtn: UIButton!
    @IBOutlet weak var MapaBtn: UIButton!
    @IBOutlet weak var SolPendImage: UIImageView!
    @IBOutlet weak var CantSolPendientes: UILabel!
    @IBOutlet weak var SolPendientesView: UIView!
    @IBOutlet weak var ExplicacionView: UIView!
    @IBOutlet weak var ExplicacionText: UILabel!
    
    
    @IBOutlet weak var AlertaEsperaView: UIView!
    @IBOutlet weak var MensajeEspera: UITextView!
    
    
    //Tarifario
    
    @IBOutlet weak var CancelarSolicitudProceso: UIButton!
    
    
    var TimerTemporal = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        //LECTURA DEL FICHERO PARA AUTENTICACION
        
        mapaVista.delegate = self
        coreLocationManager = CLLocationManager()
        coreLocationManager.delegate = self
        self.referenciaText.delegate = self
        
        if CLLocationManager.locationServicesEnabled(){
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                coreLocationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
            
            break
                
            }
        }else{
            let locationAlert = UIAlertController (title: "Error de Localización", message: "Estimado cliente es necesario que active la localización de su dispositivo.", preferredStyle: .alert)
            locationAlert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                //UIApplication.shared.open(URL(string:"App-Prefs:root=LOCATION_SERVICES")!)
                UIApplication.shared.openURL(NSURL(string:"App-Prefs:root=Privacy&path=LOCATION_SERVICES")! as URL)
            }))
            locationAlert.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
            exit(0)
            }))
            self.present(locationAlert, animated: true, completion: nil)

        }
         //solicitud de autorización para acceder a la localización del usuario

        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
        
        let JSONStyle = "[" +
            "  {" +
            "    \"featureType\": \"all\"," +
            "    \"elementType\": \"geometry.fill\"," +
            "    \"stylers\": [" +
            "      {" +
            "        \"weight\": \"2.00\"" +
            "      }" +
            "    ]" +
            "  }," +
            "       {" +
            "           \"featureType\": \"all\"," +
            "           \"elementType\": \"geometry.stroke\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#9c9c9c\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#f2f2f2\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#f2f2f2\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape.man_made\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"poi\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"off\"" +
            "           }" +
            "           ]" +
            "      }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"saturation\": -100" +
            "           }," +
            "           {" +
            "           \"lightness\": 45" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#e1e2e2\"" +
            "          }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"labels.text.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#232323\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"labels.text.stroke\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road.highway\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"simplified\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "          \"featureType\": \"road.arterial\"," +
            "           \"elementType\": \"labels.icon\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"off\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"transit\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"on\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"9aadb5\"" +
            "           }," +
            "           {" +
            "           \"visibility\": \"on\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#def5fe\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"labels.text.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#070707\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"labels.text.stroke\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            
            "  {" +
            "    \"featureType\": \"transit\"," +
            "    \"elementType\": \"labels.icon\"," +
            "    \"stylers\": [" +
            "      {" +
            "        \"visibility\": \"on\"" +
            "      }" +
            "    ]" +
            "  }" +
        "]"
        
        
        do{
            self.mapaVista.mapStyle = try GMSMapStyle(jsonString: JSONStyle)
        }catch{
            print("NO PUEDEEEEEEEEEEEEEEEEEEEEEE")
        }

        mapaVista.isMyLocationEnabled = false
        if let tempLocation = self.coreLocationManager.location?.coordinate{
            self.miposicion = tempLocation
            self.mapaVista.camera = GMSCameraPosition.camera(withLatitude: (tempLocation.latitude), longitude: (tempLocation.longitude), zoom: 15.0)
        }else{
            coreLocationManager.requestAlwaysAuthorization()
            self.mapaVista.camera = GMSCameraPosition.camera(withLatitude: -2.173714, longitude: -79.921601, zoom: 12.0)
        }
        
        //UBICAR LOS BOTONES DEL MENU
        var espacioBtn = self.view.frame.width/4
        self.CallCEnterBtn.frame = CGRect(x: espacioBtn - 40, y: 5, width: 44, height: 44)
        self.SolPendientesBtn.frame = CGRect(x: (espacioBtn * 2 - 25), y: 5, width: 44, height: 44)
        self.MapaBtn.frame = CGRect(x: (espacioBtn * 3 - 10), y: 5, width: 44, height: 44)
        self.SolPendImage.frame = CGRect(x: (espacioBtn * 2 - 10), y: 5, width: 25, height: 22)
        self.CantSolPendientes.frame = CGRect(x: (espacioBtn * 2 - 10), y: 5, width: 25, height: 22)

        self.userAnotacion = GMSMarker()
        self.taxiLocation = GMSMarker()
        self.taxiLocation.icon = UIImage(named: "taxi_libre")
        self.origenAnotacion = GMSMarker()
        self.origenAnotacion.icon = UIImage(named: "origen")
        self.destinoAnotacion = GMSMarker()
        self.destinoAnotacion.icon = UIImage(named: "destino")
        
        if myvariables.solpendientes.count > 0{
            self.CantSolPendientes.isHidden = false
            self.CantSolPendientes.text = String(myvariables.solpendientes.count)
            self.SolPendImage.isHidden = false
        }
        
        if myvariables.socket.reconnects{
            let ColaHilos = OperationQueue()
            let Hilos : BlockOperation = BlockOperation ( block: {
                self.SocketEventos()
                self.timer.invalidate()
                let url = "#U,# \n"
                self.EnviarSocket(url)
                let telefonos = "#Telefonos,# \n"
                self.EnviarSocket(telefonos)
                let datos = "OT"
                self.EnviarSocket(datos)
                if myvariables.solpendientes.count > 0{
                     self.CantSolPendientes.isHidden = false
                     self.CantSolPendientes.text = String(myvariables.solpendientes.count)
                     self.SolPendImage.isHidden = false
                }
            })
            ColaHilos.addOperation(Hilos)
        }else{
            self.Reconect()
        }
        
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            print("Permission granted")
        case AVAudioSessionRecordPermission.denied:
            print("Pemission denied")
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    
                } else{
                    
                }
            })
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            self.miposicion = (locations.last?.coordinate)!
            self.setuplocationMarker(miposicion)
            self.SolicitarBtn.isHidden = false
    }
    
    func setuplocationMarker(_ coordinate: CLLocationCoordinate2D) {
        self.userAnotacion.position = coordinate
        userAnotacion.snippet = "Cliente"
        userAnotacion.icon = UIImage(named: "origen")
        mapaVista.camera = GMSCameraPosition.camera(withLatitude: userAnotacion.position.latitude,longitude:userAnotacion.position.longitude,zoom: 14)
        self.origenIcono.isHidden = false
        ExplicacionText.text = "Localice el origen en el mapa"
        ExplicacionView.isHidden = false
        coreLocationManager.stopUpdatingLocation()
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        origenIcono.isHidden = true
        
        if SolicitarBtn.isHidden == false {
            origenAnotacion = GMSMarker(position: mapaVista.camera.target)
            self.DireccionDeCoordenada(self.origenAnotacion.position, directionText: origenText)
            origenAnotacion.icon = UIImage(named: "origen")
            origenAnotacion.snippet = origenText.text
            origenAnotacion.map = mapaVista
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            if SolicitarBtn.isHidden == false {
                origenIcono.isHidden = false
                origenAnotacion.map = nil
                self.SolPendientesView.isHidden = true
                self.ExplicacionView.isHidden = false
            }
            else{
                
            }
    }
    
    //MARK:- FUNCIONES PROPIAS
    func appUpdateAvailable() -> Bool
    {
        let storeInfoURL: String = "http://itunes.apple.com/lookup?bundleId=com.donelkys.mycab"
        var upgradeAvailable = false
        
        // Get the main bundle of the app so that we can determine the app's version number
        let bundle = Bundle.main
        if let infoDictionary = bundle.infoDictionary {
            // The URL for this app on the iTunes store uses the Apple ID for the  This never changes, so it is a constant
            let urlOnAppStore = URL(string: storeInfoURL)
            if let dataInJSON = try? Data(contentsOf: urlOnAppStore!) {
                // Try to deserialize the JSON that we got
                if let lookupResults = try? JSONSerialization.jsonObject(with: dataInJSON, options: JSONSerialization.ReadingOptions()) as! Dictionary<String, Any>{
                    // Determine how many results we got. There should be exactly one, but will be zero if the URL was wrong
                    if let resultCount = lookupResults["resultCount"] as? Int {
                        if resultCount == 1 {
                            // Get the version number of the version in the App Store
                            //self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                            if let appStoreVersion = (lookupResults["results"]as! Array<Dictionary<String, AnyObject>>)[0]["version"] as? String {
                                // Get the version number of the current version
                                if let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String {
                                    // Check if they are the same. If not, an upgrade is available.
                                    if appStoreVersion > currentVersion {
                                        upgradeAvailable = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        ///Volumes/Datos/Ecuador/Desarrollo/UnTaxi/UnTaxi/LocationManager.swift:635:31: Ambiguous use of 'indexOfObject'
        return upgradeAvailable
    }
    func SocketEventos(){
        //Evento sockect para escuchar
        //TRAMA IN: #LoginPassword,loginok,idusuario,idrol,idcliente,nombreapellidos,cantsolpdte,idsolicitud,idtaxi,cod,fechahora,lattaxi,lngtaxi,latorig,lngorig,latdest,lngdest,telefonoconductor
        if self.appUpdateAvailable(){
            
            let alertaVersion = UIAlertController (title: "Versión de la aplicación", message: "Estimado cliente es necesario que actualice a la última versión de la aplicación disponible en la AppStore. ¿Desea hacerlo en este momento?", preferredStyle: .alert)
            alertaVersion.addAction(UIAlertAction(title: "Si", style: .default, handler: {alerAction in
                
                UIApplication.shared.openURL(URL(string: "itms://itunes.apple.com/us/app/apple-store/id1280423465?mt=8")!)
            }))
            alertaVersion.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
                exit(0)
            }))
            self.present(alertaVersion, animated: true, completion: nil)

        }
        
        
        myvariables.socket.on("LoginPassword"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if (temporal[0] == "[#LoginPassword") || (temporal[0] == "#LoginPassword"){
                myvariables.solpendientes = [CSolicitud]()
                self.contador = 0
                switch temporal[1]{
                case "loginok":
                    let url = "#U,# \n"
                    self.EnviarSocket(url)
                    let telefonos = "#Telefonos,# \n"
                    self.EnviarSocket(telefonos)
                    self.idusuario = temporal[2]
                    self.SolicitarBtn.isHidden = false
                    //self.LoginView.isHidden = true
                    //self.LoginView.endEditing(true)
                    myvariables.cliente = CCliente(idUsuario: temporal[2],idcliente: temporal[4], user: self.login[1], nombre: temporal[5],email : temporal[3])
                    if temporal[6] != "0"{
                        self.ListSolicitudPendiente(temporal)
                    }
                    
                case "loginerror":
                    let fileManager = FileManager()
                    let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
                    do {
                        try fileManager.removeItem(atPath: filePath)
                    }catch{
                        
                    }
                    
                    let alertaDos = UIAlertController (title: "Autenticación", message: "Usuario y/o clave incorrectos", preferredStyle: UIAlertControllerStyle.alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        
                    }))
                    self.present(alertaDos, animated: true, completion: nil)
                case "version":
                    let alertaDos = UIAlertController (title: "Versión de la aplicación", message: "Estimado cliente es necesario que actualice a la última versión de la aplicación disponible en la AppStore. Desea hacerlo en este momento:", preferredStyle: UIAlertControllerStyle.alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        
                    }))
                    alertaDos.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
                        
                    }))
                    self.present(alertaDos, animated: true, completion: nil)
                default: print("Problemas de conexion")
                }
            }
            else{
                //exit(0)
            }
        }
        
        //Evento Posicion de taxis
        myvariables.socket.on("Posicion"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            //self.MensajeEspera.text = String(temporal)
            //self.AlertaEsperaView.hidden = false
            if(temporal[1] == "0") {
                let alertaDos = UIAlertController(title: "Solicitud de Taxi", message: "No hay taxis disponibles en este momento, espere unos minutos y vuelva a intentarlo.", preferredStyle: UIAlertControllerStyle.alert )
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.Inicio()
                }))
                
                self.present(alertaDos, animated: true, completion: nil)
            }
            else{
                self.MostrarTaxi(temporal)
            }
        }
        
        //Respuesta de la solicitud enviada
        myvariables.socket.on("Solicitud"){data, ack in
            //Trama IN: #Solicitud, ok, idsolicitud, fechahora
            //Trama IN: #Solicitud, error
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                self.MensajeEspera.text = "Solicitud enviada a todos los taxis cercanos. Esperando respuesta de un conductor."
                self.AlertaEsperaView.isHidden = false
                self.CancelarSolicitudProceso.isHidden = false
                self.ConfirmaSolicitud(temporal)
            }
            else{

            }
        }
        
        //GEOPOSICION DE TAXIS
        myvariables.socket.on("Geo"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if myvariables.solpendientes.count != 0 {
                //self.MensajeEspera.text = temporal
                //self.AlertaEsperaView.hidden = false
                for solicitudpendiente in myvariables.solpendientes{
                    if (temporal[2] == solicitudpendiente.idTaxi){
                        solicitudpendiente.taximarker.position = CLLocationCoordinate2DMake(Double(temporal[3])!, Double(temporal[4])!)
                        if solicitudpendiente.taximarker.map == self.mapaVista{
                            solicitudpendiente.taximarker.map = nil
                            solicitudpendiente.taximarker.map = self.mapaVista
                            //self.TiempoTaxi.text = solicitudpendiente.TiempoTaxi()
                        }
                    }
                }
            }
        }
        
        //ACTIVACION DEL TAXIMETRO
        myvariables.socket.on("TI"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if myvariables.solpendientes.count != 0 {
                //self.MensajeEspera.text = temporal
                //self.AlertaEsperaView.hidden = false
                for solicitudpendiente in myvariables.solpendientes{
                    if (temporal[2] == solicitudpendiente.idTaxi){
                        let alertaDos = UIAlertController (title: "Taximetro Activado", message: "Estimado Cliente: El conductor ha iniciado el Taximetro a las: \(temporal[1]).", preferredStyle: .alert)
                        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                            
                        }))
                        self.present(alertaDos, animated: true, completion: nil)
                        }
                    }
                }
        }
        
        
        //RESPUESTA DE CANCELAR SOLICITUD
        myvariables.socket.on("Cancelarsolicitud"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                let alertaDos = UIAlertController (title: "Cancelar Solicitud", message: "Su solicitud fue cancelada.", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    if myvariables.solpendientes.count != 0{
                        self.SolPendientesView.isHidden = true
                        self.CantSolPendientes.text = String(myvariables.solpendientes.count)
                    }
                    else{
                        self.SolPendImage.isHidden = true
                    }
                    self.Inicio()
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
        }
        
        //RESPUESTA DE CONDUCTOR A SOLICITUD
        
        myvariables.socket.on("Aceptada"){data, ack in
            self.Inicio()
            let temporal = String(describing: data).components(separatedBy: ",")
            //#Aceptada, idsolicitud, idconductor, nombreApellidosConductor, movilConductor, URLfoto, idTaxi, Codvehiculo, matricula, marca, color, latTaxi, lngTaxi
            if temporal[0] == "#Aceptada" || temporal[0] == "[#Aceptada"{
                var i = 0
                while myvariables.solpendientes[i].idSolicitud != temporal[1] && i < myvariables.solpendientes.count{
                    i += 1
                }
                if myvariables.solpendientes[i].idSolicitud == temporal[1]{
                    
                        let solicitud = myvariables.solpendientes[i]
                        solicitud.DatosTaxiConductor(idtaxi: temporal[6], matricula: temporal[8], codigovehiculo: temporal[7], marcaVehiculo: temporal[9],colorVehiculo: temporal[10], lattaxi: temporal[11], lngtaxi: temporal[12], idconductor: temporal[2], nombreapellidosconductor: temporal[3], movilconductor: temporal[4], foto: temporal[5])
                        
                        let alertaDos = UIAlertController (title: "Solicitud Aceptada", message: "Su vehículo se encuentra en camino, siga su trayectoria en el mapa y/o comuníquese con el conductor.", preferredStyle: .alert)
                        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                            
                            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "SolPendientes") as! SolPendController
                            vc.SolicitudPendiente = solicitud
                            vc.posicionSolicitud = myvariables.solpendientes.count - 1
                            self.navigationController?.show(vc, sender: nil)
                        }))
                    
                        self.present(alertaDos, animated: true, completion: nil)
                    }
            }
            else{
                if temporal[0] == "#Cancelada" {
                    //#Cancelada, idsolicitud
                    
                    let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Ningún vehículo aceptó su solicitud, puede intentarlo más tarde.", preferredStyle: .alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        
                    }))
                    
                    self.present(alertaDos, animated: true, completion: nil)
                }
            }
        }
        
        myvariables.socket.on("Cambioestadosolicitudconductor"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Solicitud cancelada por el conductor.", preferredStyle: UIAlertControllerStyle.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                var pos = -1
                pos = self.BuscarPosSolicitudID(temporal[1])
                if  pos != -1{
                    self.CancelarSolicitudes("Conductor")
                }
                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
                self.navigationController?.show(vc, sender: nil)
            }))
            
            self.present(alertaDos, animated: true, completion: nil)
        }
        //SOLICITUDES SIN RESPUESTA DE TAXIS
        myvariables.socket.on("SNA"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if myvariables.solpendientes.count != 0{
                for solicitudenproceso in myvariables.solpendientes{
                    if solicitudenproceso.idSolicitud == temporal[1]{
                        let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "No se encontó ningún taxi disponible para ejecutar su solicitud. Por favor inténtelo más tarde.", preferredStyle: UIAlertControllerStyle.alert)
                        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                            self.CancelarSolicitudes("")
                        }))
                        
                        self.present(alertaDos, animated: true, completion: nil)
                    }
                }
            }
        }
        
        //URl PARA AUDIO
        myvariables.socket.on("U"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            myvariables.UrlSubirVoz = temporal[1]
        }
        
        myvariables.socket.on("V"){data, ack in
            
            let temporal = String(describing: data).components(separatedBy: ",")
            myvariables.urlconductor = temporal[1]
            print(myvariables.urlconductor)
            if UIApplication.shared.applicationState != .background {
                if !myvariables.grabando{
                    myvariables.SMSProceso = true
                    myvariables.SMSVoz.ReproducirMusica()
                    myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
                }
            }else{
                if myvariables.SMSProceso{
                    print("here")
                    myvariables.SMSVoz.ReproducirMusica()
                    myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
                }else{
                    print("Esta en background")
                    let session = AVAudioSession.sharedInstance()
                }
                let localNotification = UILocalNotification()
                localNotification.alertAction = "Mensaje del Conductor"
                localNotification.alertBody = "Mensaje del Conductor. Abra la aplicación para escucharlo."
                localNotification.fireDate = Date(timeIntervalSinceNow: 4)
                UIApplication.shared.scheduleLocalNotification(localNotification)
            }
        }
        
        myvariables.socket.on("disconnect"){data, ack in
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(PantallaInicio.Reconect), userInfo: nil, repeats: true)
        }
        
        myvariables.socket.on("connect"){data, ack in
            let ColaHilos = OperationQueue()
            let Hilos : BlockOperation = BlockOperation ( block: {
                self.SocketEventos()
                self.timer.invalidate()
            })
            ColaHilos.addOperation(Hilos)
            var read = "Vacio"
            //var vista = ""
            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
            do {
                read = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
            }catch {
                
            }
            
        }
        
        myvariables.socket.on("Telefonos"){data, ack in
            //#Telefonos,cantidad,numerotelefono1,operadora1,siesmovil1,sitienewassap1,numerotelefono2,operadora2..,#
            self.TelefonosCallCenter = [CTelefono]()
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] != "0"{
                var i = 2
                while i <= temporal.count - 4{
                    let telefono = CTelefono(numero: temporal[i], operadora: temporal[i + 1].uppercased(), esmovil: temporal[i + 2], tienewhatsapp: temporal[i + 3])
                    self.TelefonosCallCenter.append(telefono)
                    i += 4
                }
                self.GuardarTelefonos(temporal)
            }
        }
        
        //RECUPERAR CLAVES
        myvariables.socket.on("Recuperarclave"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                let alertaDos = UIAlertController (title: "Recuperación de clave", message: "Su clave ha sido recuperada satisfactoriamente, en este momento ha recibido un correo electronico a la dirección: " + temporal[2], preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                }))
                
                self.present(alertaDos, animated: true, completion: nil)
            }
            
        }
        
        //CAMBIAR CLAVE
        /*#Cambiarclave,idusuario,claveold,clavenew
         evento Cambiarclave
         retorno #Cambiarclave,ok
         #Cambiarclave,error*/
        myvariables.socket.on("Cambiarclave"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                let alertaDos = UIAlertController (title: "Cambio de clave", message: "Su clave ha sido cambiada satisfactoriamente", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in

                }))
                
                self.present(alertaDos, animated: true, completion: nil)
                
            }else{
                let alertaDos = UIAlertController (title: "Cambio de clave", message: "Se produjo un error al cambiar su clave. Revise la información ingresada e inténtelo más tarde.", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in

                }))
                
                self.present(alertaDos, animated: true, completion: nil)
            }
            
        }
    }
    
    //RECONECT SOCKET
    func Reconect(){
        if contador <= 5 {
            myvariables.socket.connect()
            contador += 1
        }
        else{
            let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertControllerStyle.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                exit(0)
            }))
            
            self.present(alertaDos, animated: true, completion: nil)
        }
    }

    //FUNCIÓN ENVIAR AL SOCKET
    func EnviarSocket(_ datos: String){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.reconnects{
                myvariables.socket.emit("data",datos)
            }
            else{
                let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    exit(0)
                }))
                
                self.present(alertaDos, animated: true, completion: nil)
            }
        }else{
            ErrorConexion()
        }
    }
    
    func Inicio(){
        mapaVista!.clear()
        self.coreLocationManager.startUpdatingLocation()
        self.origenAnotacion.position = (self.coreLocationManager.location?.coordinate)!
        self.origenIcono.image = UIImage(named: "origen2")
        self.origenAnotacion.snippet = "Cliente"
        self.origenAnotacion.icon = UIImage(named: "origen")
        mapaVista.camera = GMSCameraPosition.camera(withLatitude: self.origenAnotacion.position.latitude,longitude: self.origenAnotacion.position.longitude,zoom: 15)
        self.origenIcono.isHidden = false
        ExplicacionText.text = "Localice el origen"
        ExplicacionView.isHidden = false
        if myvariables.solpendientes.count != 0 {
            self.SolPendImage.isHidden = false
            self.CantSolPendientes.text = String(myvariables.solpendientes.count)
            self.CantSolPendientes.isHidden = false
        }
        self.formularioSolicitud.isHidden = true
        self.SolicitarBtn.isHidden = false
        SolPendientesView.isHidden = true
        CancelarSolicitudProceso.isHidden = true
        AlertaEsperaView.isHidden = true

    }

    
    //FUNCION PARA LISTAR SOLICITUDES PENDIENTES
    func ListSolicitudPendiente(_ listado : [String]){
        //#LoginPassword,loginok,idusuario,idrol,idcliente,nombreapellidos,cantsolpdte,idsolicitud,idtaxi,cod,fechahora,lattaxi,lngtaxi, latorig,lngorig,latdest,lngdest,telefonoconductor
        
        var lattaxi = String()
        var longtaxi = String()
        var i = 7
        
        while i <= listado.count-10 {
            let solicitudpdte = CSolicitud()
            if listado[i+4] == "null"{
                lattaxi = "0"
                longtaxi = "0"
            }else{
                lattaxi = listado[i + 4]
                longtaxi = listado[i + 5]
            }
            solicitudpdte.idSolicitud = listado[i]
            solicitudpdte.DatosCliente(cliente: myvariables.cliente)
            solicitudpdte.DatosSolicitud(dirorigen: "", referenciaorigen: "", dirdestino: "", latorigen: listado[i + 6], lngorigen: listado[i + 7], latdestino: listado[i + 8], lngdestino: listado[i + 9],FechaHora: listado[i + 3])
            solicitudpdte.DatosTaxiConductor(idtaxi: listado[i + 1], matricula: "", codigovehiculo: listado[i + 2], marcaVehiculo: "", colorVehiculo: "", lattaxi: lattaxi, lngtaxi: longtaxi, idconductor: "", nombreapellidosconductor: "", movilconductor: listado[i + 10], foto: "")
            myvariables.solpendientes.append(solicitudpdte)
            if solicitudpdte.idTaxi != ""{
                myvariables.solicitudesproceso = true
            }
            i += 11
        }
        self.CantSolPendientes.isHidden = false
        self.CantSolPendientes.text = String(myvariables.solpendientes.count)
        self.SolPendImage.isHidden = false
    }
    
    //Funcion para Mostrar Datos del Taxi seleccionado
    func AgregarTaxiSolicitud(_ temporal : [String]){
        //#Aceptada, idsolicitud, idconductor, nombreApellidosConductor, movilConductor, URLfoto, idTaxi, Codvehiculo, matricula, marca_modelo, color, latTaxi, lngTaxi
        for solicitud in myvariables.solpendientes{
            if solicitud.idSolicitud == temporal[1]{
                myvariables.solicitudesproceso = true
                solicitud.DatosTaxiConductor(idtaxi: temporal[6], matricula: temporal[8], codigovehiculo: temporal[7], marcaVehiculo: temporal[9],colorVehiculo: temporal[10], lattaxi: temporal[11], lngtaxi: temporal[12], idconductor: temporal[2], nombreapellidosconductor: temporal[3], movilconductor: temporal[4], foto: temporal[5])
                solicitud.taximarker.map = mapaVista
                _ = RutaCliente(solicitud.origenCarrera.position, destino: solicitud.destinoCarrera.position, taxi: solicitud.taximarker.position)
                self.indexselect = myvariables.solpendientes.count - 1
                
            }
        }
    }
    
    //Crear las rutas entre los puntos de origen y destino
    func RutaCliente(_ origen: CLLocationCoordinate2D, destino: CLLocationCoordinate2D, taxi: CLLocationCoordinate2D)->[String]{
        
        var distancia = "???"
        var duracion = "???"
        let origentext = String(origen.latitude) + "," + String(origen.longitude)
        if ((taxi.latitude == 0.0 || taxi.latitude == 0) && destino.latitude != 0){
            let destinotext = String(destino.latitude) + "," + String(destino.longitude)
            let ruta = CRuta(origin: origentext, destination: destinotext)
            let routePolyline = ruta.drawRoute()
            let lines = GMSPolyline(path: routePolyline)
            lines.strokeWidth = 5
            lines.map = self.mapaVista
            lines.strokeColor = UIColor.green
            distancia = ruta.totalDistance
            duracion = ruta.totalDuration
        }
        else{
            if ((destino.latitude == 0) && (taxi.latitude != 0)){
                let taxitext = String(taxi.latitude) + "," + String(taxi.longitude)
                let ruta = CRuta(origin: origentext, destination: taxitext)
                let routePolyline = ruta.drawRoute()
                let lines = GMSPolyline(path: routePolyline)
                lines.strokeWidth = 5
                lines.map = self.mapaVista
                lines.strokeColor = UIColor.red
                distancia = ruta.totalDistance
                duracion = ruta.totalDuration
            }
            else{
                let destinotext = String(destino.latitude) + "," + String(destino.longitude)
                let taxitext = String(taxi.latitude) + "," + String(taxi.longitude)
                let rutataxi = CRuta(origin: origentext, destination: taxitext)
                let routePolylineTaxi = rutataxi.drawRoute()
                let linestaxi = GMSPolyline(path: routePolylineTaxi)
                linestaxi.strokeWidth = 4
                linestaxi.strokeColor = UIColor.red
                linestaxi.map = self.mapaVista
                duracion = rutataxi.totalDuration
                let ruta = CRuta(origin: origentext, destination: destinotext)
                let routePolyline = ruta.drawRoute()
                let lines = GMSPolyline(path: routePolyline)
                lines.strokeWidth = 5
                lines.map = self.mapaVista
                lines.strokeColor = UIColor.green
                distancia = ruta.totalDistance
            }
        }
        
        return [distancia, duracion]
    }
    
    //FUNCIÓN BUSCA UNA SOLICITUD DENTRO DEL ARRAY DE SOLICITUDES PENDIENTES DADO SU ID
    func BuscarSolicitudID(_ id : String)->CSolicitud{
        var temporal : CSolicitud!
        for solicitudpdt in myvariables.solpendientes{
            if solicitudpdt.idSolicitud == id{
                temporal = solicitudpdt
            }
        }
        return temporal
    }
    //devolver posicion de solicitud
    func BuscarPosSolicitudID(_ id : String)->Int{
        var temporal = 0
        var posicion = -1
        for solicitudpdt in myvariables.solpendientes{
            if solicitudpdt.idSolicitud == id{
                posicion = temporal
            }
            temporal += 1
        }
        return posicion
    }
    
    //GUARDAR LOS DATOS CON COREDATA
    
    func GuardarTelefonos(_ telefonos: [String]) {
        // create an instance of our managedObjectContext
        let moc = DataController().managedObjectContext
        
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Telefonos")
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try moc.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                moc.delete(managedObjectData)
            }
        } catch {
            //print("Detele all data in \(Telefonos) error : \(error) \(error.userInfo)")
        }
        
        //moc.delete(data)
        var i = 2
        while i <= telefonos.count - 4{
            let entity = NSEntityDescription.insertNewObject(forEntityName: "Telefonos", into: moc) as! Telefonos
            // add our data
            entity.setValue(telefonos[i], forKey: "numerotelefono")
            entity.setValue(telefonos[i + 1], forKey: "operadoratelefono")
            
            // we save our entity
            do {
                try moc.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            i += 4
        }
    }
    
    //Respuesta de solicitud
    func ConfirmaSolicitud(_ Temporal : [String]){
        //Trama IN: #Solicitud, ok, idsolicitud, fechahora
        
        if Temporal[1] == "ok"{
            myvariables.solpendientes.last!.RegistrarFechaHora(IdSolicitud: Temporal[2], FechaHora: Temporal[3])
            if myvariables.solpendientes.last!.destinoCarrera.position.latitude != Double(0){
                //let detalles = self.solpendientes.last!.DetallesCarrera(tarifas: tarifas)
                /*DistanciaText.text = detalles[0] + " KM"
                DuracionText.text = detalles[1]
                CostoText.text = "$" + detalles[2]
                DetallesCarreraView.isHidden = false*/
            }
            self.CantSolPendientes.isHidden = false
            self.CantSolPendientes.text = String(myvariables.solpendientes.count)
            self.SolPendImage.isHidden = false
        }
        else{
            if Temporal[1] == "error"{
                
            }
        }
    }
    //FUncion para mostrar los taxis
    func MostrarTaxi(_ temporal : [String]){
        //TRAMA IN: #Posicion,idtaxi,lattaxi,lngtaxi
        var i = 2
        while i  <= temporal.count - 6{
            let taxiTemp = GMSMarker(position: CLLocationCoordinate2DMake(Double(temporal[i + 2])!, Double(temporal[i + 3])!))
            taxiTemp.title = temporal[i]
            taxiTemp.icon = UIImage(named: "taxi_libre")
            taxiscercanos.append(taxiTemp)
            i += 6
        }
        DibujarIconos(taxiscercanos)
    }


    //FUNCIONES ESCUCHAR SOCKET
    func ErrorConexion(){
        //self.CargarTelefonos()
        //AlertaSinConexion.isHidden = false
        
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertControllerStyle.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            exit(0)
        }))

        
        self.present(alertaDos, animated: true, completion: nil)
    }
    
    //FUNCION DETERMINAR DIRECCIÓN A PARTIR DE COORDENADAS
    func DireccionDeCoordenada(_ coordenada : CLLocationCoordinate2D, directionText : UITextView){
        let geocoder = GMSGeocoder()
        var address = ""
        if CConexionInternet.isConnectedToNetwork() == true {
            let temporaLocation = CLLocation(latitude: coordenada.latitude, longitude: coordenada.longitude)
            CLGeocoder().reverseGeocodeLocation(temporaLocation, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    let placemark = (placemarks?[0])! as CLPlacemark
                    if let name = placemark.addressDictionary?["Name"] as? String {
                        address += name
                    }
                    
                    if let city = placemark.addressDictionary?["City"] as? String {
                        address += " \(city)"
                    }
                    
                    if let state = placemark.addressDictionary?["State"] as? String {
                        address += " \(state)"
                    }
                    
                    if let country = placemark.country{
                        address += " \(country)"
                    }
                    directionText.text = address
                    //self.GeolocalizandoView.isHidden = true
                }
                else {
                    directionText.text = "No disponible"
                    //self.GeolocalizandoView.isHidden = true
                }
            })
            
        }else{
            ErrorConexion()
        }
    }
    func AddressToCoordenate(address: String) {
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            self.destinoAnotacion = GMSMarker(position: CLLocationCoordinate2D(latitude: lat!, longitude: lon!))
            self.destinoAnotacion.map = self.mapaVista
        }
    }
    
    //CREAR SOLICITUD CON LOS DATOS DEL CIENTE, SU LOCALIZACIÓN DE ORIGEN Y DESTINO
    func CrearSolicitud(_ nuevaSolicitud: CSolicitud){
        //#Solicitud, idcliente, nombrecliente, movilcliente, dirorig, referencia, dirdest,latorig,lngorig, latdest, lngdest, distancia, costo, #
        formularioSolicitud.isHidden = true
        origenIcono.isHidden = true
        myvariables.solpendientes.append(nuevaSolicitud)
        self.referenciaText.text?.removeAll()
        self.origenText.text?.removeAll()
        
        let datoscliente = nuevaSolicitud.idCliente + "," + nuevaSolicitud.nombreApellidos + "," + nuevaSolicitud.user
        let datossolicitud = nuevaSolicitud.origenCarrera.snippet! + "," + nuevaSolicitud.referenciaorigen + "," + nuevaSolicitud.destinoCarrera.snippet!
        let datosgeo = String(nuevaSolicitud.distancia) + "," + nuevaSolicitud.costo
        let Datos = "#Solicitud" + "," + datoscliente + "," + datossolicitud + "," + String(nuevaSolicitud.origenCarrera.position.latitude) + "," + String(nuevaSolicitud.origenCarrera.position.longitude) + "," + String(nuevaSolicitud.destinoCarrera.position.latitude) + "," + String(nuevaSolicitud.destinoCarrera.position.longitude) + "," + datosgeo + ",# \n"
        EnviarSocket(Datos)
        MensajeEspera.text = "Procesando..."
        self.AlertaEsperaView.isHidden = false
    }
    

    //FUNCION PARA DIBUJAR LAS ANOTACIONES
    
    func DibujarIconos(_ anotaciones: [GMSMarker]){
        if anotaciones.count == 1{
            mapaVista!.camera = GMSCameraPosition.camera(withLatitude: anotaciones[0].position.latitude, longitude: anotaciones[0].position.longitude, zoom: 12)
            anotaciones[0].map = mapaVista
        }else{
            for var anotacionview in anotaciones{
                if ((anotacionview.position.latitude != 0) && (anotacionview.position.longitude != 0)){
                    anotacionview.map = mapaVista
                }
                fitAllMarkers(anotaciones)
            }
        }
    }
    
    //MOSTRAR TODOS LOS MARCADORES EN PANTALLA
    func fitAllMarkers(_ markers: [GMSMarker]) {
        var bounds = GMSCoordinateBounds()
        for marcador in markers{
            bounds = bounds.includingCoordinate(marcador.position)
        }
        mapaVista.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    //CANCELAR SOLICITUDES
    func MostrarMotivoCancelacion(){
        let motivoAlerta = UIAlertController(title: "", message: "Seleccione el motivo de cancelación.", preferredStyle: UIAlertControllerStyle.actionSheet)
        motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
                self.CancelarSolicitudes("No necesito")
   
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Demora el servicio", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
            
                self.CancelarSolicitudes("Demora el servicio")
      
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Tarifa incorrecta", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]

                self.CancelarSolicitudes("Tarifa incorrecta")
       
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Vehículo en mal estado", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]

                self.CancelarSolicitudes("Vehículo en mal estado")

        }))
        motivoAlerta.addAction(UIAlertAction(title: "Solo probaba el servicio", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]

                self.CancelarSolicitudes("Solo probaba el servicio")

        }))
        motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.destructive, handler: { action in
        }))
        self.present(motivoAlerta, animated: true, completion: nil)
    }
    
    func CancelarSolicitudes(_ motivo: String){
        //#Cancelarsolicitud, idSolicitud, idTaxi, motivo, "# \n"
        if myvariables.solpendientes.count != 0 {
            let temp = (myvariables.solpendientes.last?.idTaxi)! + "," + motivo + "," + "# \n"
            let Datos = "#Cancelarsolicitud" + "," + (myvariables.solpendientes.last?.idSolicitud)! + "," + temp
            myvariables.solpendientes.removeLast()
            
            if motivo != "Conductor"{
                EnviarSocket(Datos)
            }
        }
        self.SolPendImage.isHidden = true
        CantSolPendientes.isHidden = true
        myvariables.solicitudesproceso = false
    }
    
    //MARK:- BOTONES GRAFICOS ACCIONES
    @IBAction func CerrarApp(_ sender: Any) {
            let fileAudio = FileManager()
            let AudioPath = NSHomeDirectory() + "/Library/Caches/Audio"
            do {
                try fileAudio.removeItem(atPath: AudioPath)
            }catch{
            }
            let datos = "#SocketClose," + myvariables.cliente.idCliente + ",# \n"
            EnviarSocket(datos)
            exit(3)
    }
    @IBAction func RelocateBtn(_ sender: Any) {
        self.mapaVista.camera = GMSCameraPosition.camera(withLatitude: (self.miposicion.latitude), longitude: (self.miposicion.longitude), zoom: 15.0)
    }
    //SOLICITAR BUTTON
    @IBAction func Solicitar(_ sender: AnyObject) {
        //TRAMA OUT: #Posicion,idCliente,latorig,lngorig
        self.origenIcono.isHidden = true
        self.origenAnotacion.position = mapaVista.camera.target
        //self.DireccionDeCoordenada(self.origenAnotacion.position, directionText: origenText)
        coreLocationManager.stopUpdatingLocation()
        //self.destinoText.text?.removeAll()
        self.SolicitarBtn.isHidden = true
        ExplicacionView.isHidden = true
        self.formularioSolicitud.isHidden = false
        let datos = "#Posicion," + myvariables.cliente.idCliente + "," + "\(self.origenAnotacion.position.latitude)," + "\(self.origenAnotacion.position.longitude)," + "# \n"
        EnviarSocket(datos)
    }
    
    //Aceptar y Enviar solicitud desde formulario solicitud
    @IBAction func AceptarSolicitud(_ sender: AnyObject) {
        if !(self.referenciaText.text?.isEmpty)! {
            var origen = self.origenText.text.uppercased()
            origen = origen.replacingOccurrences(of: "Ñ", with: "N",options: .regularExpression, range: nil)
            origen = origen.replacingOccurrences(of: "[,.]", with: "-",options: .regularExpression, range: nil)
            origen = origen.replacingOccurrences(of: "[\n]", with: " ",options: .regularExpression, range: nil)
            origen = origen.replacingOccurrences(of: "[#]", with: "No",options: .regularExpression, range: nil)
            origen = origen.folding(options: .diacriticInsensitive, locale: .current)
            
            self.referenciaText.endEditing(true)
            var referencia = self.referenciaText.text.uppercased()
            referencia = referencia.replacingOccurrences(of: "Ñ", with: "N",options: .regularExpression, range: nil)
            referencia = referencia.replacingOccurrences(of: "[,.]", with: "-",options: .regularExpression, range: nil)
            referencia = referencia.replacingOccurrences(of: "[\n]", with: " ",options: .regularExpression, range: nil)
            referencia = referencia.replacingOccurrences(of: "[#]", with: "No",options: .regularExpression, range: nil)
            referencia = referencia.folding(options: .diacriticInsensitive, locale: .current)
            mapaVista.clear()
            let nuevaSolicitud = CSolicitud()
            nuevaSolicitud.DatosCliente(cliente: myvariables.cliente)
            nuevaSolicitud.DatosSolicitud(dirorigen: origen, referenciaorigen: referencia, dirdestino: "", latorigen: String(Double(origenAnotacion.position.latitude)), lngorigen: String(Double(origenAnotacion.position.longitude)), latdestino: "0", lngdestino: "0",FechaHora: "")
            self.CrearSolicitud(nuevaSolicitud)
            DibujarIconos([self.origenAnotacion])
            //self.CancelarSolicitudProceso.isHidden = false
        }else{
            
        }
    }
    
    //Boton para Cancelar Carrera
    @IBAction func CancelarSol(_ sender: UIButton) {
        self.formularioSolicitud.isHidden = true
        self.referenciaText.endEditing(true)
        self.Inicio()
        self.origenText.text?.removeAll()
        //self.destinoText.text?.removeAll()
        self.referenciaText.text?.removeAll()
        self.SolicitarBtn.isHidden = false
        if myvariables.solpendientes.count != 0{
            self.SolPendImage.isHidden = false
            self.CantSolPendientes.text = String(myvariables.solpendientes.count)
            self.CantSolPendientes.isHidden = false
        }
    }
    // CANCELAR LA SOL MIENTRAS SE ESPERA LA FONFIRMACI'ON DEL TAXI
    @IBAction func CancelarProcesoSolicitud(_ sender: AnyObject) {
        MostrarMotivoCancelacion()
    }
    
    @IBAction func MostrarTelefonosCC(_ sender: AnyObject) {
        self.SolPendientesView.isHidden = true
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "CallCenter") as! CallCenterController
        vc.telefonosCallCenter = self.TelefonosCallCenter
        self.navigationController?.show(vc, sender: nil)
        
    }
    
    @IBAction func MostrarSolPendientes(_ sender: AnyObject) {
        
        if myvariables.solpendientes.count > 0{
        
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ListaSolPdtes") as! SolicitudesTableController
        vc.solicitudesMostrar = myvariables.solpendientes
        self.navigationController?.show(vc, sender: nil)
        }else{
            self.ExplicacionView.isHidden = !self.ExplicacionView.isHidden
            self.SolPendientesView.isHidden = !self.SolPendientesView.isHidden
        }
        
    }
    @IBAction func TaximetroMenu(_ sender: AnyObject) {
        self.SolPendientesView.isHidden = true
    }
    
    @IBAction func TarifarioMenu(_ sender: AnyObject) {
        self.SolPendientesView.isHidden = true
    }
    @IBAction func MapaMenu(_ sender: AnyObject) {
        Inicio()
    }
    @IBAction func CompartirApp(_ sender: Any) {
        if let name = URL(string: "itms://itunes.apple.com/us/app/apple-store/id1280423465?mt=8") {
            let objectsToShare = [name]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.present(activityVC, animated: true, completion: nil)
        }
        else
        {
            // show alert for not available
        }

    }

    //MARK:- CONTROL DE TECLADO VIRTUAL
    //Funciones para mover los elementos para que no queden detrás del teclado

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text.removeAll()
        animateViewMoving(true, moveValue: 200, view: self.view)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(false, moveValue: 200, view: self.view)
        self.EnviarSolBtn.isEnabled = true
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.EnviarSolBtn.isEnabled = true
    }

    func animateViewMoving (_ up:Bool, moveValue :CGFloat, view : UIView){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        view.frame = view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.referenciaText.resignFirstResponder()
    }
}
