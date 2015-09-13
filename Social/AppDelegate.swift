//
//  AppDelegate.swift
//  Social
//
//  Created by Vladimir Goncharov on 29.08.15.
//  Copyright (c) 2015 FlatStack. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Twitter.sharedInstance().startWithConsumerKey("x0Ao3SWSmX6Xm7Mjqg3Q8Ykgg", consumerSecret: "x62gj7RL45ZkmUI8lTLYRGDWDlaLCbNBQuKCYqbznX0aSKqcyt")
        //setting Fabric
        Fabric.with([Crashlytics.self(), Twitter.self()])
        
        //setting VK
        VKSdk.initializeWithDelegate(self, andAppId: "5057927")
        VKSdk.wakeUpSession()
        
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
        FBSession.activeSession().handleDidBecomeActive()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication) == true {
            return true
        }
        
        if VKSdk.processOpenURL(url, fromApplication: sourceApplication) == true {
            return true
        }
        
        return false
    }

}

//MARK: -
extension AppDelegate : VKSdkDelegate {
    
    func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
        NSNotificationCenter.defaultCenter().postNotificationName(kVKDidUpdateTokenNotification, object: newToken)
    }
    
    func vkSdkRenewedToken(newToken: VKAccessToken!) {
        NSNotificationCenter.defaultCenter().postNotificationName(kVKDidUpdateTokenNotification, object: newToken)
    }
    
    func vkSdkUserDeniedAccess(authorizationError: VKError!) {
        NSNotificationCenter.defaultCenter().postNotificationName(kVKDeniedAccessNotification, object: authorizationError)
    }
    
    func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        NSNotificationCenter.defaultCenter().postNotificationName(kVKHasExperiedTokenNotification, object: expiredToken)
    }
    
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        self.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        let captchaController        = VKCaptchaViewController.captchaControllerWithError(captchaError)
        self.window?.rootViewController?.presentViewController(captchaController, animated: true, completion: nil)
    }
    
}
