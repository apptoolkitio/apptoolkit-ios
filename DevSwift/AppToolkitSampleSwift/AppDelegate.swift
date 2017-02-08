//
//  AppDelegate.swift
//  AppToolkitSampleSwift
//
//  Created by Rizwan Sattar on 7/23/15.
//  Copyright (c) 2015 Cluster Labs, Inc. All rights reserved.
//

import UIKit
import AppToolkit

let USE_LOCAL_APPTOOLKIT_SERVER = false
let APPTOOLKIT_TOKEN: String = "YOUR_APPTOOLKIT_TOKEN"

@UIApplicationMain
class AppDelegate: UIResponder, UIAlertViewDelegate, UIApplicationDelegate {

    var window: UIWindow?

    // token warning
    var alertController: UIAlertController?
    var alertView: UIAlertView?

    // TODO: Listen for NSUserDefaultsDidChangeNotification and start AppToolkit again if so


    var availableAppTookitToken: String? {

        var appToolkitToken: String? = APPTOOLKIT_TOKEN
        if let token = appToolkitToken where token == "YOUR_APPTOOLKIT_TOKEN" {
            // Otherwise fetch the AppToolkit token from the Settings bundle
            if let tokenInSettings = NSUserDefaults.standardUserDefaults().objectForKey("appToolkitToken") as? String {
                appToolkitToken = tokenInSettings
            }
        }
        if (appToolkitToken != nil && (appToolkitToken!.characters.count == 0 || appToolkitToken! == "YOUR_APPTOOLKIT_TOKEN")) {
            // Our token is non-nil but is not valid (empty or unusable default)
            return nil
        }
        return appToolkitToken
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSUserDefaults.standardUserDefaults().registerDefaults(["appToolkitToken" : APPTOOLKIT_TOKEN])
        // In case, you the developer, has directly modified the AppToolkit token here

        self.startAppToolkitIfPossible()
        AppToolkit.sharedInstance().presentOnboardingUIOnWindow(self.window!, completionHandler: nil)
        return true
    }

    func startAppToolkitIfPossible() -> Bool {
        guard let appToolkitToken = self.availableAppTookitToken where !AppToolkit.hasLaunched() else {
            return false
        }

        // Valid token, so create AppToolkit instance
        if USE_LOCAL_APPTOOLKIT_SERVER {
            AppToolkit.useLocalAppToolkitServer(true)
        }
        AppToolkit.launchWithToken(appToolkitToken)
        AppToolkit.sharedInstance().debugMode = true
        AppToolkit.sharedInstance().verboseLogging = true
        AppToolkit.sharedInstance().debugAppUserIsAlwaysSuper = true
        // Use convenience method for setting up the ready-handler
        ATKConfigReady({
            print("Config is ready")
        })
        // Use the normal method for setting up the refresh handler
        AppToolkit.sharedInstance().config.refreshHandler = { (oldParameters, newParameters) -> Void in
            print("Config was refreshed!")
            if ATKAppUserIsSuper() {
                print("User is considered super!")
            }
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        if self.availableAppTookitToken != nil {

            if self.alertController != nil {
                self.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else if self.alertView != nil {
                self.alertView?.dismissWithClickedButtonIndex(self.alertView!.cancelButtonIndex, animated: true)
            }
            self.alertController = nil
            self.alertView = nil

            if !AppToolkit.hasLaunched() {
                self.startAppToolkitIfPossible()
            }

        } else {
            if self.alertController == nil && self.alertView == nil {
                // If we've never shown this alert before
                let title = "Set AppToolkit Token"
                let msg = "You must go to Settings and enter in your AppToolkit token."

                if NSClassFromString("UIAlertController") != nil {
                    self.alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
                    self.alertController!.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: { [unowned self] (action) -> Void in
                        self.alertController = nil
                    }))
                    self.alertController!.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { [unowned self] (action) -> Void in
                        self.alertController = nil
                        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                    }))
                    self.window?.rootViewController?.presentViewController(self.alertController!, animated: true, completion: nil)
                } else {
                    self.alertView = UIAlertView(title: title, message: msg, delegate: self, cancelButtonTitle: "Okay")
                    self.alertView!.show()
                }
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        self.alertView = nil
    }


}

