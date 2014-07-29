//
//  LTGRoomPlacesFixedReader.swift
//  room-spaces-cocoapod
//
//  Created by PauloGF on 6/30/14.
//  Copyright (c) 2014 LTG. All rights reserved.
//

import Foundation

protocol LTGRoomPlacesFixedReaderDelegate{
    func beaconManager()
}

class LTGRoomPlacesFixedReader: NSObject, ESTBeaconManagerDelegate {
    var rangeThreshold : Float = 0.0
    var timeoutInterval : NSNumber = 3000
    let manager : AFHTTPRequestOperationManager
    var delegate: LTGRoomPlacesFixedReaderDelegate?
    var beaconsInRange : [LTGRoomPlacesESTBeacon ] = []
    var beaconThresholdDictionary = Dictionary<String, Double>()
    var allBeacons : [LTGRoomPlacesESTBeacon ] = []
    var beaconWithStrongestRSSI : LTGRoomPlacesESTBeacon?
    var isMovingReader : Bool = false;
    var isBeacon : Bool = false;
    var isCalibrating : Bool = true;
    let beaconManager : ESTBeaconManager
    var beaconRegion : ESTBeaconRegion
    var dbIDs : [String] = []
    let clientID : String = UIDevice.currentDevice().identifierForVendor.UUIDString
    var client : MQTTClient
    var kMQTTServerHost = "q.m2m.io"
    var name = "reader-1"

    
    init(){
        self.client  = MQTTClient(clientId: self.clientID)
        self.manager = AFHTTPRequestOperationManager()
        self.beaconManager = ESTBeaconManager()
        self.beaconRegion = ESTBeaconRegion(proximityUUID: NSUUID(UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D"), identifier: "LTG")
        manager.securityPolicy.allowInvalidCertificates = true //not recommende in production
    }
    
    func startRanging() {
        beaconManager.delegate = self
        isMovingReader = false;
        isBeacon = false;
        beaconManager.startRangingBeaconsInRegion(self.beaconRegion)
        println("LTGRoomPlaces: Initializing calibration as fixed reader")
    }
    
    func setRangeThreshold(newRange: Float) {
        rangeThreshold = newRange
    }
    
    
    ///////////////////////////
    func beaconManager(manager: ESTBeaconManager, didRangeBeacons: [ESTBeacon], inRegion:ESTBeaconRegion){
        
        for cBeacon in didRangeBeacons{
            let sBeacon : ESTBeacon = cBeacon
            let distFactor = (Double(sBeacon.rssi) + 30.0)/Double(-70.0);
            
            if let beacon = beaconForIDAll(sBeacon.minor.stringValue) {
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
            if isCalibrating {
                if distFactor <= Double(self.rangeThreshold) && distFactor > 0.0 {
                    if let beaconInRange = beaconForIDRange(sBeacon.minor.stringValue) {
                        beaconInRange.setLastSigh(NSDate().timeIntervalSinceReferenceDate*1000)
                        beaconInRange.setRSSI(sBeacon.rssi)
                        beaconInRange.setDistFactor(distFactor)
                    }
                    else{
                        let beaconInRange : LTGRoomPlacesESTBeacon = LTGRoomPlacesESTBeacon()
                        beaconInRange.setName("ESTIMOTE")
                        beaconInRange.setID(sBeacon.minor.stringValue)
                        beaconInRange.setRSSI(sBeacon.rssi)
                        beaconInRange.setDistFactor(distFactor)
                        beaconInRange.setLastSigh(NSDate().timeIntervalSinceReferenceDate*1000)
                        self.beaconsInRange.append(beaconInRange)
                    }
                }
            }
            else{
                if beaconThresholdDictionary.count > 0 {
                    if let s = beaconThresholdDictionary[sBeacon.minor.stringValue]{
                        if distFactor <= s && distFactor > 0.0 {
                            if let beaconInRange = beaconForIDRange(sBeacon.minor.stringValue) {
                                beaconInRange.setLastSigh(NSDate().timeIntervalSinceReferenceDate*1000)
                                beaconInRange.setRSSI(sBeacon.rssi)
                                beaconInRange.setDistFactor(distFactor)
                            }
                            else{
                                println("New Beacon In Range : \(sBeacon.minor.stringValue)")
                                let beaconInRange : LTGRoomPlacesESTBeacon = LTGRoomPlacesESTBeacon()
                                beaconInRange.setName("ESTIMOTE")
                                beaconInRange.setID(sBeacon.minor.stringValue)
                                beaconInRange.setRSSI(sBeacon.rssi)
                                beaconInRange.setDistFactor(distFactor)
                                beaconInRange.setLastSigh(NSDate().timeIntervalSinceReferenceDate*1000)
                                self.beaconsInRange.append(beaconInRange)
                                self.sendMessage("\(beaconInRange.getID()) at \(self.name)", topics: ["public/estimote/arrivals"])
                            }
                        }
                    }
                }
            }
        }
        checkAllBeaconsAge()
        if let l = delegate{
            delegate?.beaconManager()
        }
    }
    
    func changeRegionUUID(UUID_ :String) {
        var beaconRegion : ESTBeaconRegion = ESTBeaconRegion(proximityUUID:
            NSUUID(UUIDString: UUID_), identifier: "LTG")
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
        println("LTGRoomPlacesManager: Region UUID changed")
    }
    
    func getBeaconWithStrongestRSSI() -> LTGRoomPlacesESTBeacon?{
        var beaconToReturn : LTGRoomPlacesESTBeacon?
        if let beacon = beaconWithStrongestRSSI {
            beaconToReturn = beacon
            return beaconToReturn
        }
        return beaconToReturn
    }
    
    func beaconForIDAll(id:String)->LTGRoomPlacesESTBeacon?{
        var beaconToReturn : LTGRoomPlacesESTBeacon?
        for eBeacon in allBeacons{
            if eBeacon.getID() == id{
                beaconToReturn  = eBeacon
                return beaconToReturn
            }
        }
        return beaconToReturn
    }
    
    func connectMQTT(){
        
        self.client.connectToHost(self.kMQTTServerHost, completionHandler: { (code: MQTTConnectionReturnCode) -> Void in
            
            if code.value == ConnectionAccepted.value {
                self.client.publishString("\(self.clientID) connected ", toTopic: "public/estimote/connections", withQos: AtMostOnce, retain: true, completionHandler: { mid in
                    println("MQTT message delivered");
                    })
                println("Connection Accepted")
            } else {
                println("return code \(code.value)")
            }
            
            })
    }
    
    func subscribeTopic(topic: String) {
        
        client.subscribe(topic, withCompletionHandler: { grantedQos in
            println("subscribed to topic \(topic)");
            
            })
        
    }
    
    func sendMessage(message: String, topics: [String]) {
        for topic in topics {
            self.client.publishString(message, toTopic: topic, withQos: AtMostOnce, retain: false, completionHandler: { mid in
                println("message has been delivered");
                })
        }
    }
    
    
    func beaconForIDRange(id:String)->LTGRoomPlacesESTBeacon?{
        var beaconToReturn : LTGRoomPlacesESTBeacon?
        for eBeacon in beaconsInRange{
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
                println("Beacon departure : \(allBeacons[index].getID())")
                allBeacons.removeAtIndex(index)
                --index
            }
        }
        
        for var index = 0; index < beaconsInRange.count; ++index {
            if isBeaconAgedOut(beaconsInRange[index]){
                println("Beacon departure : \(beaconsInRange[index].getID())")
                self.sendMessage("\(beaconsInRange[index].getID()) from \(self.name)", topics: ["public/estimote/departures"])
                beaconsInRange.removeAtIndex(index)
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
    
    func getFromPhysicalResourcesDB(){
        manager.GET("http://ltg.evl.uic.edu/drowsy/room-places-test/physical-resources", parameters: nil, success: {
            (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in //println("JSON: " + responseObject.description)
            let json = JSONValue(responseObject)
            self.configTh(json)
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                println("Error: " + error.localizedDescription)
            })
    }
    
    func postToPhysicalResourcesDB(){
        var beaconsJSONArray : [AnyObject] = []
        
        for eBeacon in beaconsInRange{
            let s = eBeacon.getDistFactor().doubleValue + 0.02
            beaconsJSONArray.append(["est_id": "\(eBeacon.getID())", "dist_factor": s])
        }
        
        manager.POST("https://ltg.evl.uic.edu/drowsy/room-places-test/physical-resources",
            parameters: ["run_id":"test", "estimotes":beaconsJSONArray],
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                println("JSON: " + responseObject.description)
                self.getConfigDB()
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                println("Error: " + error.localizedDescription)
            })
    }
    
    func getConfigDB(){
        self.dbIDs = []
        manager.GET("http://ltg.evl.uic.edu/drowsy/room-places-test/physical-resources", parameters: nil, success: {
            (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in //println("JSON: " + responseObject.description)
            let json = JSONValue(responseObject)
            for elem in json.array!{
                self.dbIDs.append(elem["_id"]["$oid"].string!)
            }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                println("Error: " + error.localizedDescription)
            })
    }
    
    func clearDB(){
        for elem in self.dbIDs {
            manager.DELETE("http://ltg.evl.uic.edu/drowsy/room-places-test/physical-resources/"+elem, parameters: nil, success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in println("JSON: " + responseObject.description)
                },
                failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    println("Error: " + error.localizedDescription)
                })
        }
    }
    
    func exitCalibration(){
        beaconManager.stopRangingBeaconsInRegion(beaconRegion)
        allBeacons = []
        beaconsInRange = []
        isCalibrating = false
        beaconThresholdDictionary = Dictionary<String, Double>()
        getFromPhysicalResourcesDB()
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func configTh(responseObj:JSONValue){
        if let arr = responseObj[0]["estimotes"].array {
            for elem in arr {
                let id : String = elem["est_id"].string!
                let th : Double = elem["dist_factor"].double!
                self.beaconThresholdDictionary[id]=th
            }
        }
    }
    
    
}