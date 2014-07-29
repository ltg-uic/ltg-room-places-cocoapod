//
//  ViewController.swift
//  room-spaces-cocoapod
//
//  Created by PauloGF on 6/17/14.
//  Copyright (c) 2014 LTG. All rights reserved.
//

import UIKit



class FixedReaderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var numBeacons: UILabel = UILabel()
    @IBOutlet var numBeaconsWithinRange: UILabel = UILabel()
    @IBOutlet var configButton: UIButton
    @IBOutlet var testButton: UIButton
    @IBOutlet var cleanButton: UIButton
    @IBOutlet var configRangeSlider: UISlider
    @IBOutlet var tableViewEstimotes: UITableView
    
    var loaded : Bool = false
    
    override func viewDidLoad() {
        println("loading fixed reader view controller")
        super.viewDidLoad()
        numBeacons.textAlignment = NSTextAlignment.Center
        numBeacons.text = "0"
        configRangeSlider.value = 1.0
        appDelegate().fixedReaderViewController = self
        appDelegate().thisDevice.startRanging()
        configRangeSliderChanged(configRangeSlider)
    }
    
    override func viewWillAppear(animated: Bool) {
        println("loading fixed reader view controller")
        appDelegate().thisDevice.isCalibrating = true
    }
    
    //action test button
    @IBAction func testButtonPressed(button:UIButton) {
        println("testButtonPressed")
        self.performSegueWithIdentifier("fixTest", sender: self)
        appDelegate().thisDevice.exitCalibration()
    }
    
    @IBAction func cleanButtonPressed(button:UIButton) {
        println("cleanButtonPressed")
        appDelegate().thisDevice.clearDB()
    }

    //action configuration button
    @IBAction func configButtonPressed(button:UIButton) {
        println("configButtonPressed")
        appDelegate().thisDevice.postToPhysicalResourcesDB()
    }
    
    @IBAction func configRangeSliderChanged(slider:UISlider){
        println("configRangeSliderChanged")
        appDelegate().thisDevice.setRangeThreshold(slider.value)
    }
    
    func updateTotalNumberOfBeaconsLabel(newText : String){
        if self.isViewLoaded(){
            numBeacons.text = newText
        }
    }
    
    func updateNumberOfBeaconsInRangeLabel(newText : String){
        if self.isViewLoaded(){
            numBeaconsWithinRange.text = newText
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func appDelegate()->AppDelegate{
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        return app
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate().thisDevice.beaconsInRange.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var cell = tableViewEstimotes.dequeueReusableCellWithIdentifier("customCell") as CustomTableViewCell
        
        var beacon : LTGRoomPlacesESTBeacon = self.appDelegate().thisDevice.beaconsInRange[indexPath.row]
        
        cell.idLabel.text = beacon.getID()
        cell.rssiLabel.text = String(format:"%.2f", beacon.getDistFactor().floatValue)
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println("You selected cell #\(indexPath.row)!")
    }
    
    
}



