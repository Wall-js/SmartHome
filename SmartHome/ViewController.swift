//
//  ViewController.swift
//  SmartHome
//
//  Created by ckd－macpro on 2018/3/13.
//  Copyright © 2018年 ckd－macpro. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let modbus = Modbus(ipAddress: "192.168.3.120", port: 502, device: 1)
        
        modbus.connect(
            success: { () -> Void in
                //connected and ready to do modbus calls
                print("connected")
        },
            failure: { (error: NSError) -> Void in
                //Handle error
                print(error)
        })
        modbus.readBitsFrom(startAddress: 0, count: 30,
                            success: { (array: [AnyObject]) -> Void in
                                //Do something with the returned data (NSArray of NSNumber)..
                                print("success: \(array)")
        },
                            failure:  { (error: NSError) -> Void in
                                //Handle error
                                print("error")
        })
        modbus.readRegistersFrom(startAddress: 0, count: 30,
                            success: { (array: [AnyObject]) -> Void in
                                //Do something with the returned data (NSArray of NSNumber)..
                                print("success: \(array)")
        },
                            failure:  { (error: NSError) -> Void in
                                //Handle error
                                print("error")
        })
        modbus.disconnect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

