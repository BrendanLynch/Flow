//
//  AppDelegate.swift
//  Flow
//
//  Created by Brendan Lynch on 2015-04-28.
//  Copyright (c) 2015 Volley. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSURLSessionDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var statusItem:NSStatusItem?
    var menu:NSMenu = NSMenu()
    
    var sessionConfig:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    var session:NSURLSession?
    
    var flowArray:NSArray = []
    
    let flowEndpoint = "SERVER_URL_HERE"

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        statusItem?.image = NSImage(named: "Volley")
        statusItem?.highlightMode = true
        
        menu.delegate = self
        menu.removeAllItems()
        statusItem?.menu = menu
        
        sessionConfig.allowsCellularAccess = true
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        sessionConfig.HTTPMaximumConnectionsPerHost = 1
        
        session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
    }
    
    func changeStatus(sender:NSMenuItem) { // toggle the status value
        let obj:NSDictionary = sender.representedObject as! NSDictionary
        let status:NSNumber = obj["status"] as! NSNumber
        let name:NSString = obj["name"] as! NSString
        
        let endpoint:NSString = NSString(format: "%@/%@", flowEndpoint, name)
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: endpoint as String)!)
        request.HTTPMethod = "PUT"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let newStatus:NSNumber = status == 0 ? 1 : 0
        
        let dataString:NSString = NSString(format: "status=%@", newStatus)

        let flowTask:NSURLSessionUploadTask = session!.uploadTaskWithRequest(request, fromData: dataString.dataUsingEncoding(NSUTF8StringEncoding), completionHandler: nil)
        flowTask.resume()
    }
    
    func menuWillOpen(menu: NSMenu) {
        menu.removeAllItems()
        
        var menuItem = NSMenuItem(title: "Loading...", action: nil, keyEquivalent: "")
        menu.addItem(menuItem)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))) , dispatch_get_main_queue(), {
            let flowTask:NSURLSessionTask = self.session!.dataTaskWithURL(NSURL(string: self.flowEndpoint)!, completionHandler: {(data, response, error) in
                var jsonError:NSError?
                var flowJSON:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as! NSDictionary
                self.flowArray = flowJSON["flow"] as! NSArray
                
                menu.removeAllItems()
                
                let statusValues = ["👋", "🚫"]
                var count:Int = 0
                dispatch_async(dispatch_get_main_queue(), {
                    for flow in self.flowArray {
                        if count > 0 {
                            menu.addItem(NSMenuItem.separatorItem())
                        }
                        let status:NSNumber = flow["status"] as! NSNumber
                        let name:NSString = flow["name"] as! NSString
                        let flowString:NSString = NSString(format: "%@ %@", statusValues[status.integerValue], name)
                        menuItem = NSMenuItem(title: flowString as String, action: "changeStatus:", keyEquivalent: "")
                        menuItem.representedObject = flow
                        menu.addItem(menuItem)
                        count++
                    }
                })
            })
            flowTask.resume()
        })
    }
}
