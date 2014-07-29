//
//  LTGRoomPlacesJSON.swift
//  room-spaces-cocoapod
//
//  Created by PauloGF on 7/11/14.
//  Copyright (c) 2014 LTG. All rights reserved.
//

import Foundation


func JSONParseArray(jsonString: String) -> Array<AnyObject> {
    var e: NSError?
    var data: NSData=jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    var jsonObj = NSJSONSerialization.JSONObjectWithData(
        data,
        options: NSJSONReadingOptions(0),
        error: &e) as Array<AnyObject>
    if e {
        return Array<AnyObject>()
    } else {
        return jsonObj
    }
}

func JSONParseDict(jsonString:String) -> Dictionary<String, AnyObject> {
    var e: NSError?
    var data:NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    var jsonObj = NSJSONSerialization.JSONObjectWithData(
        data,
        options: NSJSONReadingOptions(0),
        error: &e) as Dictionary<String, AnyObject>
    if e {
        return Dictionary<String, AnyObject>()
    } else {
        return jsonObj
    }
}

func JSONStringify(jsonObj: AnyObject) -> String {
    var e: NSError?
    let jsonData = NSJSONSerialization.dataWithJSONObject(
        jsonObj,
        options: NSJSONWritingOptions(0),
        error: &e)
    if e {
        return ""
    } else {
        return NSString(data: jsonData, encoding: NSUTF8StringEncoding)
    }
}