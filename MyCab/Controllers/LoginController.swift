//
//  LoginController.swift
//  UnTaxi
//
//  Created by Done Santana on 26/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import SocketIO

class LoginController: UIViewController, UITextFieldDelegate{
    
    var login = [String]()
    var solitudespdtes = [CSolicitud]()
    
    //MARK:- VARIABLES INTERFAZ
    
    @IBOutlet weak var Usuario: UITextField!
    @IBOutlet weak var Clave: UITextField!
    @IBOutlet weak var AutenticandoView: UIView!
    
    @IBOutlet weak var ClaveRecover: UIView!
    @IBOutlet weak var movilClaveRecover: UITextField!
    @IBOutlet weak var RecuperarClaveBtn: UIButton!
    
    
    @IBOutlet weak var RegistroView: UIView!
    @IBOutlet weak var nombreApText: UITextField!
    @IBOutlet weak var claveText: UITextField!
    @IBOutlet weak var confirmarClavText: UITextField!
    @IBOutlet weak var correoText: UITextField!
    @IBOutlet weak var telefonoText: UITextField!
    @IBOutlet weak var RegistroBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        telefonoText.delegate = self
        claveText.delegate = self
        correoText.delegate = self
        self.Usuario.delegate = self
        self.movilClaveRecover.delegate = self
        confirmarClavText.delegate = self
        Clave.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
        
        self.RegistroView.addGestureRecognizer(tapGesture)
        self.ClaveRecover.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(tapGesture)
        
        //Verificar Actualizaciones
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
        
        
        if CConexionInternet.isConnectedToNetwork() == true{
           
            myvariables.socket = SocketIOClient(socketURL: URL(string: "http://173.249.14.205:6037")!, config: [.log(false), .forcePolling(true)])
            myvariables.socket.connect()

            myvariables.socket.on("connect"){data, ack in
                print("Conectadooo")
                var read = "Vacio"
                let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
                do {
                    read = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
                }catch {
                }
                if read != "Vacio"
                {
                    self.AutenticandoView.isHidden = false
                    self.Login()
                }
                else{
                    self.AutenticandoView.isHidden = true
                }
                self.SocketEventos()
            }
            
        }else{
            ErrorConexion()
        }


    }
    
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
        myvariables.socket.on("LoginPassword"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if (temporal[0] == "[#LoginPassword") || (temporal[0] == "#LoginPassword"){
                //self.solpendientes = [CSolicitud]()
                //self.contador = 0
                switch temporal[1]{
                case "loginok":
                    myvariables.cliente = CCliente(idUsuario: temporal[2],idcliente: temporal[4], user: self.login[1], nombre: temporal[5],email: temporal[3])
                    if temporal[6] != "0"{
                        self.ListSolicitudPendiente(temporal)
                    }
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
                    self.navigationController?.show(vc, sender: nil)
                    
                case "loginerror":
                    let fileManager = FileManager()
                    let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
                    do {
                        try fileManager.removeItem(atPath: filePath)
                    }catch{
                        
                    }
                    
                    let alertaDos = UIAlertController (title: "Autenticación", message: "Usuario y/o clave incorrectos", preferredStyle: UIAlertControllerStyle.alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        self.AutenticandoView.isHidden = true
                    }))
                    self.present(alertaDos, animated: true, completion: nil)
                default: print("Problemas de conexion")
                }
            }
            else{
                //exit(0)
            }
        }
        
        myvariables.socket.on("Registro") {data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            
            if temporal[1] == "registrook"{
                
                let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Registro Realizado con éxito, puede loguearse en la aplicación, ¿Desea ingresar a la Aplicación?", preferredStyle: .alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.RegistroView.isHidden = true
                }))
                alertaDos.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
                    exit(0)
                }))
                
                self.present(alertaDos, animated: true, completion: nil)
            }
            else{
                
                let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Error al registrar el usuario: \(temporal[2])", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.AutenticandoView.isHidden = true
                }))
                
                self.present(alertaDos, animated: true, completion: nil)
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
        
    }

    
    //MARK:- FUNCIONES PROPIAS
    
    func Login(){
        var readString = ""
        let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
        
        do {
            readString = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
        } catch {
        }
        self.login = String(readString).components(separatedBy: ",")
        EnviarSocket(readString)
    }

    
    //FUNCIÓN ENVIAR AL SOCKET
    func EnviarSocket(_ datos: String){
        if CConexionInternet.isConnectedToNetwork() == true{
            print(myvariables.socket.reconnects)
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

    //MARK:- ACCIONES DE LOS BOTONES
    //LOGIN Y REGISTRO DE CLIENTE
    @IBAction func Autenticar(_ sender: AnyObject) {
        let writeString = "#LoginPassword," + self.Usuario.text! + "," + self.Clave.text! + ",# \n"
        //CREAR EL FICHERO DE LOGÍN
        let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
        
        do {
            _ = try writeString.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            
        } catch {
            
        }
        self.Login()
    }
    
    @IBAction func OlvideClave(_ sender: AnyObject) {
        ClaveRecover.isHidden = false
        self.Usuario.resignFirstResponder()
        self.Clave.resignFirstResponder()
    }
    
    @IBAction func RecuperarClave(_ sender: AnyObject) {
        //"#Recuperarclave,numero de telefono,#"
        let datos = "#Recuperarclave," + movilClaveRecover.text! + ",# \n"
        EnviarSocket(datos)
        ClaveRecover.isHidden = true
        movilClaveRecover.endEditing(true)
        movilClaveRecover.text?.removeAll()
    }
    
    @IBAction func CancelRecuperarclave(_ sender: AnyObject) {
        ClaveRecover.isHidden = true
        self.movilClaveRecover.endEditing(true)
        self.movilClaveRecover.text?.removeAll()
    }

    @IBAction func RegistrarCliente(_ sender: AnyObject) {
        self.Usuario.resignFirstResponder()
        self.Clave.resignFirstResponder()
        RegistroView.isHidden = false
        
    }
    @IBAction func EnviarRegistro(_ sender: AnyObject) {
        if (nombreApText.text!.isEmpty || telefonoText.text!.isEmpty || claveText.text!.isEmpty) {
            let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertControllerStyle.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                
            }))

            self.present(alertaDos, animated: true, completion: nil)
        }
        else{
            let temporal = "," + telefonoText.text! + "," + telefonoText.text! + "," + claveText.text!
            var temporal1 = ",Sin correo" + ",# \n"
            if correoText.text != ""{
                temporal1 = "," + correoText.text! + "," + "# \n"
            }
            let datos = "#Registro" + "," + nombreApText.text! + temporal + temporal1
            myvariables.socket.emit("data", datos)
        }
        RegistroView.isHidden = true
        claveText.endEditing(true)
        confirmarClavText.endEditing(true)
        correoText.endEditing(true)
    }
    
    @IBAction func CancelarRegistro(_ sender: AnyObject) {
        RegistroView.isHidden = true
        claveText.endEditing(true)
        confirmarClavText.endEditing(true)
        correoText.endEditing(true)
        
        
        nombreApText.text?.removeAll()
        telefonoText.text?.removeAll()
        claveText.text?.removeAll()
        confirmarClavText.text?.removeAll()
        correoText.text?.removeAll()
    }


    //MARK:- CONTROL DE TECLADO VIRTUAL
    //Funciones para mover los elementos para que no queden detrás del teclado
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black
        textField.text?.removeAll()
            if textField.isEqual(claveText) || textField.isEqual(Clave) || textField.isEqual(Usuario){
                animateViewMoving(true, moveValue: 80, view: self.view)
            }
            else{
                if textField.isEqual(movilClaveRecover){
                    textField.text?.removeAll()
                    animateViewMoving(true, moveValue: 105, view: self.view)
                }
                else{
                    if textField.isEqual(confirmarClavText) || textField.isEqual(correoText){
                            textField.tintColor = UIColor.black
                            animateViewMoving(true, moveValue: 155, view: self.view)
                        }else{
                        if textField.isEqual(self.telefonoText){
                            textField.textColor = UIColor.black
                            animateViewMoving(true, moveValue: 70, view: self.view)
                        }
                    }
        }
        }
    }
    func textFieldDidEndEditing(_ textfield: UITextField) {
        textfield.text = textfield.text!.replacingOccurrences(of: ",", with: ".")
            if textfield.isEqual(claveText) || textfield.isEqual(Clave) || textfield.isEqual(Usuario){
                    animateViewMoving(false, moveValue: 80, view: self.view)
            }else{
                if textfield.isEqual(confirmarClavText) || textfield.isEqual(correoText){
                    if textfield.text != claveText.text && textfield.isEqual(confirmarClavText){
                            textfield.textColor = UIColor.red
                            textfield.text = "Las claves no coinciden"
                            textfield.isSecureTextEntry = false
                            RegistroBtn.isEnabled = false
                        }
                        else{
                            RegistroBtn.isEnabled = true
                        }
                    animateViewMoving(false, moveValue: 155, view: self.view)
                    }else{
                        if textfield.isEqual(telefonoText){
                            animateViewMoving(false, moveValue: 70, view: self.view)
                        }else{
                            if textfield.isEqual(movilClaveRecover){
                                if movilClaveRecover.text?.characters.count != 10{
                                    textfield.text = "Número de Teléfono Incorrecto"
                                }else{
                                    self.RecuperarClaveBtn.isEnabled = true
                                }
                                animateViewMoving(false, moveValue: 105, view: self.view)
                            }
                        }
                    }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if textField.isEqual(self.Clave){
            let writeString = "#LoginPassword," + self.Usuario.text! + "," + self.Clave.text! + ",# \n"
            //CREAR EL FICHERO DE LOGÍN
            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
            
            do {
                _ = try writeString.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
                
            } catch {
                
            }
            self.Login()
        }
        return true
    }
    
    @objc func ocultarTeclado(){
        self.ClaveRecover.endEditing(true)
        self.RegistroView.endEditing(true)
    }

    
}
