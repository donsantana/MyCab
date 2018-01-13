//
//  CRuta.swift
//  Xtaxi
//
//  Created by usuario on 15/3/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class CRuta{
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    var selectedRoute = Dictionary<String, AnyObject>()
    var overviewPolyline = Dictionary<String, AnyObject>()
    //var overviewPolyline = GMSPath()
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var originAddress: String!
    var destinationAddress: String!
    var totalDistanceInMeters: Double = 0.0
    var totalDistance: String = "0"
    var totalDurationInSeconds: UInt = 0
    var totalDuration: String = "0"
    
    init(origin: String, destination: String){
        
        var directionsURLString = baseURLDirections + "origin=" + origin + "&destination=" + destination
        directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let directionsURL = URL(string: directionsURLString)
        
        
        let directionsData = try! Data(contentsOf: directionsURL!)
        do {
            let dictionary = try JSONSerialization.jsonObject(with: directionsData, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any>
            let status = dictionary["status"] as! String
            if status == "OK"{
                
                self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                
                let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                
                let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                
                let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                
                self.originAddress = legs[0]["start_address"] as! String
                self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
                
                self.calculateTotalDistanceAndDuration()
            }
            
        }catch{
            print("ni mierda")
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func calculateTotalDistanceAndDuration() {
        
        /*let origenLocation: CLLocation = CLLocation(coordinate: self.originCoordinate.latitude, altitude: self.originCoordinate.longitude)
         let destinoLocation: CLLocation = CLLocation(latitude: self.destinationCoordinate.latitude, longitude: self.destinationCoordinate.longitude)
         self.totalDistance = origenLocation.distance(from: destinoLocation)*/
        
        let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
        
        totalDistanceInMeters = 0.0
        totalDurationInSeconds = 0
        
        for leg in legs {
            totalDistanceInMeters += leg["distance"]?["value"] as! Double
            totalDurationInSeconds += leg["duration"]?["value"] as!  UInt
        }
        let distanceInKilometers = totalDistanceInMeters / 1000
        
        self.totalDistance = String(format:"%.2f", distanceInKilometers)
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        //let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        self.totalDuration = "\(remainingHours)h:\(remainingMins)m:\(remainingSecs)s"
    }
    
    func displayRouteInfo() ->[String]{
        return [self.totalDistance,self.totalDuration]
    }
    
    func drawRoute()->GMSPath{
        let route = self.overviewPolyline["points"] as! String
        return GMSPath(fromEncodedPath: route)!
    }
    
}
