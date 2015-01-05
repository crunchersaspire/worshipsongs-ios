//
//  AppDelegate.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/16/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var progressView: UIView!
    let utilClass:Util = Util()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if(ConnectionService.isConnectedToNetwork()){
            let statusType = ConnectionService.isConnectedToNetworkOfType()
            switch statusType{
            case .WWAN:
               utilClass.downloadFile()
            case .WiFi:
                utilClass.downloadFile()
            case .NotConnected:
                println("Connection Type: Not connected to the Internet")
            }
        }
        else
        {
            println("Internet Connection: Unavailable")
        }
        // Util.parseJson()
        sleep(10)
       // progressView.animateProgressView()
        //let tableViewController = TableViewController(style: UITableViewStyle.Grouped)
        let masterViewController = MasterViewController(style:UITableViewStyle.Grouped)
        let navController = UINavigationController(rootViewController: masterViewController)
        navController.navigationBar.barTintColor = UIColor.grayColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navController.navigationBar.titleTextAttributes = titleDict
       // Util.copyFile("songs.sqlite")
                
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    

}
