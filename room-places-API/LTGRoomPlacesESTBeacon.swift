//
//  LTGRoomPlacesBeacon.swift
//  room-spaces-cocoapod
//
//  Created by PauloGF on 6/19/14.
//  Copyright (c) 2014 LTG. All rights reserved.
//

import Foundation


class LTGRoomPlacesESTBeacon {
    var name : String = ""
    var id : String = ""
    var type : String = "receiver"
    var rssi : NSNumber = 0.0
    var lastSigh : NSNumber = 0.0
    var rangeThreshold : NSNumber = 0.5
    var distFactor : NSNumber = 0.0

    
    ///getters
    
    func getID() -> String{
        return id
    }
    
    func getType() -> String{
        return type
    }

    func getRSSI() -> NSNumber{
        return rssi
    }
    
    func getLastSigh() -> NSNumber{
        return lastSigh
    }
    
    func getDistFactor() -> NSNumber{
        return distFactor
    }

    
    //setters
    
    func setName(name_:String){
        self.name = name_
    }
    
    func setID(id_:String){
        self.id = id_
    }
    
    func setRSSI(rssi_ : NSNumber){
        self.rssi = rssi_
    }
    
    func setType(type_ : String){
        self.type = type_
     }

    func setLastSigh(lastSigh_ : NSNumber){
        self.lastSigh = lastSigh_
    }
    
    func setRangeThreshold(rangeThreshold_ : NSNumber){
        self.rangeThreshold = rangeThreshold_
    }
    
    func setDistFactor(distFactor_ : NSNumber){
        self.distFactor = distFactor_
    }


}