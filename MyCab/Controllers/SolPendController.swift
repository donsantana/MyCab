//
//  SolPendController.swift
//  UnTaxi
//
//  Created by Done Santana on 28/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import GoogleMaps
import SocketIO

class SolPendController: UIViewController, GMSMapViewDelegate, UITextViewDelegate,URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    var SolicitudPendiente: CSolicitud!
    var posicionSolicitud: Int!
    //var OrigenSolicitud = GMSMarker()
    //var DestinoSolicitud = GMSMarker()
    //var TaxiSolicitud = GMSMarker()
    var evaluacion: CEvaluacion!
    //var SMSVoz = CSMSVoz()
    var grabando = false
    var fechahora: String!
    var UrlSubirVoz = myvariables.UrlSubirVoz
    //var urlconductor: String!

    
    //MASK:- VARIABLES INTERFAZ
    @IBOutlet weak var MapaSolPen: GMSMapView!
    @IBOutlet weak var DetallesCarreraView: UIView!
    @IBOutlet weak var DistanciaText: UILabel!
    @IBOutlet weak var DuracionText: UILabel!
    
    @IBOutlet weak var EvaluarBtn: UIButton!
    @IBOutlet weak var EvaluacionView: UIView!
    @IBOutlet weak var ComentarioEvalua: UIView!
    @IBOutlet weak var PrimeraStart: UIButton!
    @IBOutlet weak var SegundaStar: UIButton!
    @IBOutlet weak var TerceraStar: UIButton!
    @IBOutlet weak var CuartaStar: UIButton!
    @IBOutlet weak var QuintaStar: UIButton!
    @IBOutlet weak var ComentarioText: UITextView!
    
    @IBOutlet weak var MensajesBtn: UIButton!
    @IBOutlet weak var LlamarCondBtn: UIButton!
    @IBOutlet weak var SMSVozBtn: UIButton!
    
    
    @IBOutlet weak var DatosConductor: UIView!
    //datos del conductor a mostrar
    @IBOutlet weak var ImagenCond: UIImageView!
    @IBOutlet weak var NombreCond: UILabel!
    @IBOutlet weak var MovilCond: UILabel!
    @IBOutlet weak var MarcaAut: UILabel!
    @IBOutlet weak var ColorAut: UILabel!
    @IBOutlet weak var MatriculaAut: UILabel!

    @IBOutlet weak var AlertaEsperaView: UIView!
    @IBOutlet weak var MensajeEspera: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.MapaSolPen.delegate = self
        self.ComentarioText.delegate = self
        MapaSolPen.camera = GMSCameraPosition.camera(withLatitude: self.SolicitudPendiente.origenCarrera.position.latitude,longitude: self.SolicitudPendiente.origenCarrera.position.longitude,zoom: 15)
        
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.normalTap))
        let longGesture = UILongPressGestureRecognizer(target: self, action: "longTap:")
        longGesture.minimumPressDuration = 0.5
        //tapGesture.numberOfTapsRequired = 1
        //self.SMSVozBtn.addGestureRecognizer(tapGesture)
        self.SMSVozBtn.addGestureRecognizer(longGesture)
        
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
            self.MapaSolPen.mapStyle = try GMSMapStyle(jsonString: JSONStyle)
        }catch{
            print("NO PUEDEEEEEEEEEEEEEEEEEEEEEE")
        }

        //MASK:- EVENTOS SOCKET
        myvariables.socket.on("Taxi"){data, ack in
            //"#Taxi,"+nombreconductor+" "+apellidosconductor+","+telefono+","+codigovehiculo+","+gastocombustible+","+marcavehiculo+","+colorvehiculo+","+matriculavehiculo+","+urlfoto+","+idconductor+",# \n";
            let datosConductor = String(describing: data).components(separatedBy: ",")
            print(datosConductor)
            self.NombreCond.text! = "Conductor: " + datosConductor[1]
            self.MarcaAut.text! = "Marca: " + datosConductor[5]
            self.ColorAut.text! = "Color: " + datosConductor[6]
            self.MatriculaAut.text! = "Matrícula: " + datosConductor[7]
            self.MovilCond.text! = "Movil: " + datosConductor[2]
            if datosConductor[8] != "null" && datosConductor[8] != ""{
                let url = URL(string:datosConductor[8])
                let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    DispatchQueue.main.sync() {
                        self.ImagenCond.image = UIImage(data: data)
                    }
                }
                task.resume()
            }else{
                self.ImagenCond.image = UIImage(named: "chofer")
            }
            self.AlertaEsperaView.isHidden = true
            self.DatosConductor.isHidden = false
        }
        
        myvariables.socket.on("V"){data, ack in

            self.MensajesBtn.isHidden = false
            self.MensajesBtn.setImage(UIImage(named: "mensajesnew"),for: UIControlState())
        }
        
        if myvariables.urlconductor != ""{
            self.MensajesBtn.isHidden = false
            self.MensajesBtn.setImage(UIImage(named: "mensajesnew"),for: UIControlState())
        }
        
        self.MostrarDetalleSolicitud()
    }

    
    
    //MASK:- FUNCIONES PROPIAS
    func longTap(_ sender : UILongPressGestureRecognizer){
      if sender.state == .ended {
        if !myvariables.SMSVoz.reproduciendo && myvariables.grabando{
            self.SMSVozBtn.setImage(UIImage(named: "smsvoz"), for: .normal)
                let dateFormato = DateFormatter()
                dateFormato.dateFormat = "yyMMddhhmmss"
                self.fechahora = dateFormato.string(from: Date())
                let name = self.SolicitudPendiente.idSolicitud + "-" + self.SolicitudPendiente.idTaxi + "-" + fechahora + ".m4a"
                myvariables.SMSVoz.TerminarMensaje(name)
                myvariables.SMSVoz.SubirAudio(myvariables.UrlSubirVoz, name: name)
                myvariables.grabando = false
        }
    }else if sender.state == .began {
        if !myvariables.SMSVoz.reproduciendo{
            self.SMSVozBtn.setImage(UIImage(named: "smsvozRec"), for: .normal)
                myvariables.SMSVoz.ReproducirMusica()
                myvariables.SMSVoz.GrabarMensaje()
                myvariables.grabando = true
            }
        }
    }
    
    //ENVIAR EVALUACIÓN
    func EnviarEvaluacion(_ evaluacion: Int, comentario: String){
        EvaluacionView.isHidden = true
        self.ComentarioText.text = "Escriba su comentario..."
        let idsolicitud = self.SolicitudPendiente.idSolicitud
        let datos = "#Evaluar," + idsolicitud + "," + String(evaluacion) + "," + comentario + ",# \n"
        EnviarSocket(datos)
    }
    
    //FUNCIÓN ENVIAR AL SOCKET
    func EnviarSocket(_ datos: String){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.reconnects{
                myvariables.socket.emit("data",datos)
                print(datos)
            }else{
                let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    exit(0)
                }))
                
                self.present(alertaDos, animated: true, completion: nil)
            }
        }else{
            self.ErrorConexion()
        }
    }

    func ErrorConexion(){
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertControllerStyle.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            exit(0)
        }))
        
        self.present(alertaDos, animated: true, completion: nil)
    }
    
    func MostrarDetalleSolicitud(){
        
        //self.OrigenSolicitud = self.SolicitudPendiente.origenCarrera
        self.SolicitudPendiente.origenCarrera.map = self.MapaSolPen

        if self.SolicitudPendiente.idTaxi != "null" && self.SolicitudPendiente.idTaxi != ""{
            //self.TaxiSolicitud = self.SolicitudPendiente.taximarker
            self.SolicitudPendiente.taximarker.map = self.MapaSolPen
            let temporal = self.SolicitudPendiente.TiempoTaxi()
            DistanciaText.text = temporal[0] + " KM"
            DuracionText.text = temporal[1]
            DetallesCarreraView.isHidden = false
            self.SMSVozBtn.setImage(UIImage(named:"smsvoz"),for: UIControlState())
            self.SolicitudPendiente.DibujarRutaSolicitud(mapa: MapaSolPen)
            
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(self.SolicitudPendiente.origenCarrera.position)
            bounds = bounds.includingCoordinate(self.SolicitudPendiente.taximarker.position)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
            self.MapaSolPen.animate(with: update)
        }

    }
    
    //CANCELAR SOLICITUDES
    func MostrarMotivoCancelacion(){
        let motivoAlerta = UIAlertController(title: "", message: "Seleccione el motivo de cancelación.", preferredStyle: UIAlertControllerStyle.actionSheet)
        motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
                self.CancelarSolicitud("No necesito")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Demora el servicio", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
           self.CancelarSolicitud("Demora el servicio")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Tarifa incorrecta", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
            self.CancelarSolicitud("Tarifa incorrecta")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Vehículo en mal estado", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
            self.CancelarSolicitud("Vehículo en mal estado")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Solo probaba el servicio", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
            self.CancelarSolicitud("Solo probaba el servicio")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.destructive, handler: { action in
        }))
        
        self.present(motivoAlerta, animated: true, completion: nil)
    }
    
    func CancelarSolicitud(_ motivo: String){
        //#Cancelarsolicitud, idSolicitud, idTaxi, motivo, "# \n"
        let Datos = "#Cancelarsolicitud" + "," + self.SolicitudPendiente.idSolicitud + "," + self.SolicitudPendiente.idTaxi + "," + motivo + "," + "# \n"
        EnviarSocket(Datos)
        myvariables.solpendientes.remove(at: self.posicionSolicitud)
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
        self.navigationController?.show(vc, sender: nil)        
    }


    //MASK:- ACCIONES DE BOTONES
    //BOTONES PARA EVALUCIÓN DE CARRERA
    @IBAction func EvaluarMapaBtn(_ sender: AnyObject) {
        self.evaluacion = CEvaluacion(botones: [PrimeraStart, SegundaStar,TerceraStar,CuartaStar,QuintaStar])
        EvaluacionView.isHidden = false
    }
    
    @IBAction func Star1(_ sender: AnyObject) {
        self.evaluacion.EvaluarCarrera(1)
        self.ComentarioText.isHidden = false
    }
    @IBAction func Star2(_ sender: AnyObject) {
        self.evaluacion.EvaluarCarrera(2)
        self.ComentarioText.isHidden = false
    }
    @IBAction func Star3(_ sender: AnyObject) {
        self.evaluacion.EvaluarCarrera(3)
        self.ComentarioText.isHidden = false
    }
    @IBAction func Star4(_ sender: AnyObject) {
        self.evaluacion.EvaluarCarrera(4)
        self.ComentarioText.isHidden = false
    }
    @IBAction func Star5(_ sender: AnyObject) {
        self.evaluacion.EvaluarCarrera(5)
        self.ComentarioText.isHidden = false
    }
    //Enviar comentario
    @IBAction func AceptarEvalucion(_ sender: AnyObject) {
        EnviarEvaluacion(self.evaluacion.PtoEvaluacion,comentario: self.ComentarioText.text)
        self.ComentarioText.endEditing(true)
    }
    
    
    //LLAMAR CONDUCTOR
    @IBAction func LLamarConductor(_ sender: AnyObject) {
        if let url = URL(string: "tel://\(self.SolicitudPendiente.movil)") {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func ReproducirMensajesCond(_ sender: AnyObject) {
        if myvariables.urlconductor != ""{
            myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
        }
    }
    
    //MARK:- BOTNES ACTION
    @IBAction func DatosConductor(_ sender: AnyObject) {
        if self.SolicitudPendiente.marcaVehiculo != ""{
            self.NombreCond.text! = "Conductor: " + self.SolicitudPendiente.nombreApellido
            self.MarcaAut.text! = "Marca: " + self.SolicitudPendiente.marcaVehiculo
            self.ColorAut.text! = "Color: " + self.SolicitudPendiente.colorVehiculo
            self.MatriculaAut.text! = "Matrícula: " + self.SolicitudPendiente.matricula
            self.MovilCond.text! = "Movil: " + self.SolicitudPendiente.movil
            if self.SolicitudPendiente.urlFoto != "null" && self.SolicitudPendiente.urlFoto != ""{
                let url = URL(string:self.SolicitudPendiente.urlFoto)
                let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    DispatchQueue.main.sync() {
                        self.ImagenCond.image = UIImage(data: data)
                    }
                }
                task.resume()
            }else{
                self.ImagenCond.image = UIImage(named: "chofer")
            }
            self.DatosConductor.isHidden = false
        }else{
            let datos = "#Taxi," + myvariables.cliente.idUsuario + "," + self.SolicitudPendiente.idTaxi + ",# \n"
            self.EnviarSocket(datos)
            MensajeEspera.text = "Procesando..."
            AlertaEsperaView.isHidden = false
        }
    }
    
    @IBAction func AceptarCond(_ sender: UIButton) {
        self.DatosConductor.isHidden = true        
    }
    
    @IBAction func NuevaSolicitud(_ sender: Any) {
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
        self.navigationController?.show(vc, sender: nil)
    }
    

    @IBAction func CancelarProcesoSolicitud(_ sender: AnyObject) {
        MostrarMotivoCancelacion()
    }


    //MARK:- TEXT DELEGATE ACTION
    func textViewDidBeginEditing(_ textView: UITextView) {
     if textView.isEqual(ComentarioText){
        textView.text.removeAll()
        animateViewMoving(true, moveValue: 110, view: self.ComentarioEvalua)
     }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
     if textView.isEqual(ComentarioText){
        animateViewMoving(false, moveValue: 110,view: self.ComentarioEvalua)
     }
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
    

}
