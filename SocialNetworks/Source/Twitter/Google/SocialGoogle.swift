//
//  SocialGoogle.swift
//  Adme
//
//  Created by Kruperfone on 23.11.15.
//  Copyright © 2015 Flatstack. All rights reserved.
//

import Foundation
import Google

private var defaultDelegate = GoogleSignInDelegate()
private var uiDefaultDelegate = GoogleSignInUIDelegate()

public class GoogleNetwork: NSObject {
    
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
    
    public static func setup() -> Void {
        
        var error: NSError?
        GGLContext.sharedInstance().configureWithError(&error)
        guard error == nil else {return}
        
        GIDSignIn.sharedInstance().delegate = defaultDelegate
        GIDSignIn.sharedInstance().uiDelegate = uiDefaultDelegate
    }
    
    public class func name() -> String {
        return "Google"
    }
    
    public class func isAuthorized() -> Bool {
        return GIDSignIn.sharedInstance().hasAuthInKeychain()
    }
    
    public class func authorization(completion: SocialNetworkSignInCompletionHandler?) {
        if (self.isAuthorized()) {
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


