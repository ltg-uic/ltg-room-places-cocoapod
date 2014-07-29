//
//  LTGRoomPlacesManager.swift
//  room-spaces-cocoapod
//
//  Created by PauloGF on 6/19/14.
//  Copyright (c) 2014 LTG. All rights reserved.
//

import Foundation
import UIKit

protocol LTGRoomPlacesManagerDelegate{
    func beaconManager()
}

class LTGRoomPlacesManager: NSObject, ESTBeaconManagerDelegate {
    
    var range : Double = 0.0
    var timeoutInterval : NSNumber = 1500
    
    var delegate: LTGRoomPlacesManagerDelegate?
    let beaconManager : ESTBeaconManager = ESTBeaconManager()
    var beaconRegion : ESTBeaconRegion = ESTBeaconRegion(proximityUUID: NSUUID(UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D"), identifier: "LTG")
    var beaconsInRange : [LTGRoomPlacesESTBeacon ] = []
    var allBeacons : [LTGRoomPlacesESTBeacon ] = []
    var beaconWithStrongestRSSI : LTGRoomPlacesESTBeacon?

    var isMovingReader : Bool = false;
    var isBeacon : Bool = false;
    
    func initManagerAsStationaryReader() {
        self.isMovingReader = false;
        self.isBeacon = false;
        beaconManager.delegate = self
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
        println("LTGRoomPlacesManager: Manager started as Receiver")
    }
    
    func initManagerAsMovingReader() {
        self.isMovingReader = true;
        self.isBeacon = false;
        beaconManager.delegate = self
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
        println("LTGRoomPlacesManager: Manager started as Receiver")
    }
    
    func initManagerAsBeacon() {
        self.isMovingReader = false;
        self.isBeacon = true;
        beaconManager.delegate = self
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
        println("LTGRoomPlacesManager: Manager started as Beacon")
    }
    
    func changeRegionUUID(UUID_ :String) {
        var beaconRegion : ESTBeaconRegion = ESTBeaconRegion(proximityUUID:
            NSUUID(UUIDString: UUID_), identifier: "LTG")
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
        println("LTGRoomPlacesManager: Region UUID changed")
    }
    
    ///////////////////////////
    func beaconManager(manager: ESTBeaconManager, didRangeBeacons: [ESTBeacon], inRegion: ESTBeaconRegion){
       
        var prevBeacon : LTGRoomPlacesESTBeacon?

        for cBeacon in didRangeBeacons{
            let sBeacon : ESTBeacon = cBeacon
            let distFactor = (Double(sBeacon.rssi) + 30.0)/Double(-70.0);
            
            
            if !isMovingReader && !isBeacon{
                if let beacon = beaconForID(sBeacon.minor.stringValue) {
                    beacon.setLastSigh(NSDate().timeIntervalSinceReferenceDate*1000)
                    beacon.setRSSI(sBeacon.rssi)
                    beacon.setDistFactor(distFactor)
                }
                else{
                    let beacon : LTGRoomPlacesESTBeacon = LTGRoomPlacesESTBeacon()
                    beacon.setName("ESTIMOTE")
                    beacon.setID(sBeacon.minor.stringValue)
                    beacon.setRSSI(sBeacon.rssi)
                    beacon.setDistFactor(distFactor)
                    beacon.setLastSigh(NSDate().timeIntervalSinceReferenceDate*1000)
                    allBeacons.append(beacon)
                }
            }
            else if isMovingReader && !isBeacon {
                if let beacon = beaconWithStrongestRSSI {
                    if distFactor > beacon.distFactor.doubleValue + 0.1 {
                        beaconWithStrongestRSSI = LTGRoomPlacesESTBeacon()
                        beaconWithStrongestRSSI!.setName("ESTIMOTE")
                        beaconWithStrongestRSSI!.setID(sBeacon.minor.stringValue)
                        beaconWithStrongestRSSI!.setRSSI(sBeacon.rssi)
                        beaconWithStrongestRSSI!.setDistFactor(distFactor)
                        beaconWithStrongestRSSI!.setLastSigh(NSDate().timeIntervalSinceReferenceDate*1000)
                    }
                }
                else{
                    beaconWithStrongestRSSI = LTGRoomPlacesESTBeacon()
                    beaconWithStrongestRSSI!.setName("ESTIMOTE")
                    beaconWithStrongestRSSI!.setID(sBeacon.minor.stringValue)
                    beaconWithStrongestRSSI!.setRSSI(sBeacon.rssi)
                    beaconWithStrongestRSSI!.setDistFactor(distFactor)
                    beaconWithStrongestRSSI!.setLastSigh(NSDate().timeIntervalSinceReferenceDate*1000)
                }
            }
            else if isBeacon && !isMovingReader{
                //to be implemented
            }
            else{
                println("LTGRoomPlacesManager: Configuration error. Device can be either Reader or Beacon. Not both...")
            }
        }
        checkAllBeaconsAge()
        delegate?.beaconManager()
        //numBeacons.text = "\(beaconsInRange.count)"
    }
    
    func getBeaconWithStrongestRSSI() -> LTGRoomPlacesESTBeacon?{
        var beaconToReturn : LTGRoomPlacesESTBeacon?
        if let beacon = beaconWithStrongestRSSI {
            beaconToReturn = beacon
            return beaconToReturn
        }
        return beaconToReturn
    }
    
    func beaconForID(id:String)->LTGRoomPlacesESTBeacon?{
        var beaconToReturn : LTGRoomPlacesESTBeacon?
        for eBeacon in self.allBeacons{
            if eBeacon.getID() == id{
                beaconToReturn  = eBeacon
                return beaconToReturn
            }
        }
        return beaconToReturn
    }
    
    func checkAllBeaconsAge (){
        for var index = 0; index < allBeacons.count; ++index {
            if isBeaconAgedOut(allBeacons[index]){
                allBeacons.removeAtIndex(index)
                --index
            }
        }
    }
    
    func isBeaconAgedOut(beacon:LTGRoomPlacesESTBeacon) -> Bool {
        var now : NSNumber = NSDate().timeIntervalSinceReferenceDate * 1000
        var then : NSNumber = beacon.lastSigh
        if now.intValue - then.intValue >= timeoutInterval.intValue {
            return true
        }
        return false
    }
}

