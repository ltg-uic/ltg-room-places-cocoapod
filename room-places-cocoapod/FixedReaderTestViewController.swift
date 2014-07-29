//
//  FixedReaderTestViewController.swift
//  room-spaces-cocoapod
//
//  Created by PauloGF on 7/16/14.
//  Copyright (c) 2014 LTG. All rights reserved.
//

import UIKit

//UITableViewDataSource


class FixedReaderTestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var numBeacons: UILabel = UILabel()
    @IBOutlet var tableViewEstimotesInRange: UITableView
    
    var loaded : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numBeacons.textAlignment = NSTextAlignment.Center
        numBeacons.text = "0"
        appDelegate().fixedReaderTestViewController = self
        appDelegate().thisDevice.sendMessage("hola", topics: ["public/testltg"])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateTotalNumberOfBeaconsLabel(newText : String){
        if self.isViewLoaded(){
            numBeacons.text = newText
        }
    }
    
    func appDelegate()->AppDelegate{
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        return app
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate().thisDevice.beaconsInRange.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        
        var cell = tableViewEstimotesInRange.dequeueReusableCellWithIdentifier("customCell2") as CustomTableViewCell
        
        var beacon : LTGRoomPlacesESTBeacon = self.appDelegate().thisDevice.beaconsInRange[indexPath.row]
        
        cell.idLabel.text = beacon.getID()
        cell.rssiLabel.text = String(format:"%.2f", beacon.getDistFactor().floatValue)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println("You selected cell #\(indexPath.row)!")
    }
    
}