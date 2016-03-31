//
//  SocialGoogle.swift
//  Adme
//
//  Created by Kruperfone on 23.11.15.
//  Copyright © 2015 Flatstack. All rights reserved.
//

import Foundation

private let defaultDelegate = GoogleSignInDelegate()
private let uiDefaultDelegate = GoogleSignInUIDelegate()

public class GoogleNetwork: NSObject {
    
    public class var shared: GoogleNetwork {
        struct Static {
            static var instance: GoogleNetwork?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            var error: NSError?
            GGLContext.sharedInstance().configureWithError(&error)
            guard error == nil else { fatalError("Google not initializated.\nError: \(error)") }
            
            GIDSignIn.sharedInstance().delegate = defaultDelegate
            GIDSignIn.sharedInstance().uiDelegate = uiDefaultDelegate
            
            Static.instance = GoogleNetwork()
        }
        
        return Static.instance!
    }
    
    private override init() {
        super.init()
    }
    
    public class func setNewUIDelegate(delegate: GIDSignInUIDelegate) -> Void {
        GIDSignIn.sharedInstance().uiDelegate = delegate
    }
    
    public class func setDefaultUIDelegate() -> Void {
        GIDSignIn.sharedInstance().uiDelegate = uiDefaultDelegate
    }
    
    private class var currentUserID: String? {
        get {
            let user = GIDSignIn.sharedInstance().currentUser
            return user?.authentication.idToken
        }
    }
}

//MARK: - SocialNetwork
extension GoogleNetwork: SocialNetwork {
    
    public static var name: String {
        return "Google"
    }

    public static var isAuthorized: Bool {
        return GIDSignIn.sharedInstance().hasAuthInKeychain()
    }
    
    public class func authorization(completion: SocialNetworkSignInCompletionHandler?) {
        if (self.isAuthorized) {
            completion?(success: true, error: nil)
        } else {
            defaultDelegate.signInCompletition = completion
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    public class func logout(completion: SocialNetworkSignOutCompletionHandler?) {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        completion?()
    }
}


//MARK: -
private class GoogleSignInDelegate: NSObject {
    var signInCompletition: SocialNetworkSignInCompletionHandler?
}

extension GoogleSignInDelegate: GIDSignInDelegate {
    @objc func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        self.signInCompletition?(success: user != nil, error: error)
        self.signInCompletition = nil
    }
}


//MARK: -
private class GoogleSignInUIDelegate: NSObject {
}

extension GoogleSignInUIDelegate: GIDSignInUIDelegate {
    @objc func signIn(signIn: GIDSignIn!, presentViewController viewController: UIViewController!) {
        self.presentOnRootController(viewController)
    }
    
    @objc private func presentOnRootController(controller: UIViewController) {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
    }
}


