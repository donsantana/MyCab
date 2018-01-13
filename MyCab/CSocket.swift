//
//  CSocket.swift
//  Xtaxi
//
//  Created by Done Santana on 15/10/15.
//  Copyright © 2015 Done Santana. All rights reserved.
//

import Foundation
import SocketIO


//Clase CSocket

class CSocket {

    private var socket: SocketIOClient
    var resultado = "Inicial"
   //constructor
    init(severAddress: String){
    self.socket = SocketIOClient(socketURL: URL(string: severAddress)!, config: [.log(false), .forcePolling(true)])
    //self.ControlEventos()
    self.socket.connect()
    }
    
    //Control de eventos desde el servidor
    func ControlEventos(){
        
    }
    //Desconectar
    func Desconectar(){
     self.socket.disconnect()
    }
    
}
