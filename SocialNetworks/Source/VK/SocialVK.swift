import UIKit

//MARK: -
private let defaultDelegate = VKNetworkDelegate.init()
private let uiDefaultDelegate = VKNetworkUIDelegate.init()

public class VKNetwork: NSObject {
    
    public static var permissions:[String] = ["photos", "wall", "email"]
    
    public class var shared: VKNetwork {
        struct Static {
            static var instance: VKNetwork?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            let instance = VKNetwork()
            if VKSdk.instance().uiDelegate == nil {
                self.setDefaultUIDelegate()
            }
            VKSdk.instance().registerDelegate(defaultDelegate)
            VKSdk.wakeUpSession(VKNetwork.permissions) { (state, error) -> Void in
                if let lError = error {
                    #if swift(>=2.2)
                        debugPrint("\(#function) - is received error \(lError)")
                    #else
                        debugPrint("\(__FUNCTION__) - is received error \(lError)")
                    #endif
                    
                } else {
                    #if swift(>=2.2)
                        debugPrint("\(#function) - is updated state \(state.rawValue)")
                    #else
                        debugPrint("\(__FUNCTION__) - is updated state \(state.rawValue)")
                    #endif
                }
            }
            Static.instance = instance
        }
        
        return Static.instance!
    }
    
    private override init() {
        super.init()
    }
    
    public class func setNewUIDelegate(delegate: VKSdkUIDelegate) -> Void {
        VKSdk.instance().uiDelegate = delegate
    }
    
    public class func setDefaultUIDelegate() -> Void {
        VKSdk.instance().uiDelegate = uiDefaultDelegate
    }
}

//MARK:-
extension VKNetwork: SocialNetwork {
    
    public class var name: String {
        return "VK"
    }
    
    public class var isAuthorized: Bool {
        return VKSdk.isLoggedIn()
    }
    
    public class func authorization(completion: SocialNetworkSignInCompletionHandler?) {
        if (self.isAuthorized) {
            completion?(success: true, error: nil)
        } else {
            self.openNewSession(completion)
        }
    }
    
    public class func logout(completion: SocialNetworkSignOutCompletionHandler?) {
        if self.isAuthorized == true {
            VKSdk.forceLogout()
        }
        completion?()
    }
    
    private class func openNewSession(completion: SocialNetworkSignInCompletionHandler?) {
        VKSdk.authorize(VKNetwork.permissions)
        
        defaultDelegate.completion = completion
    }
}

//MARK: -
private class VKNetworkDelegate: NSObject {
    var completion: SocialNetworkSignInCompletionHandler? = nil
}

extension VKNetworkDelegate: VKSdkDelegate {
    @objc private func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
        if result?.token != nil && result?.user != nil {
            self.completion?(success: true, error: nil)
        } else {
            self.completion?(success: false, error: result?.error)
        }
        
        self.completion = nil
    }
    
    @objc private func vkSdkUserAuthorizationFailed() {
        self.completion?(success: false, error: nil)
        self.completion = nil
    }
    
    @objc private func vkSdkAccessTokenUpdated(newToken: VKAccessToken!, oldToken: VKAccessToken!) {
        self.completion?(success: true, error: nil)
        self.completion = nil
    }
    
    @objc private func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        self.completion?(success: false, error: nil)
        self.completion = nil
    }
}

//MARK: -
private class VKNetworkUIDelegate: NSObject {
}

extension VKNetworkUIDelegate: VKSdkUIDelegate {
    
    @objc private func vkSdkShouldPresentViewController(controller: UIViewController!) {
        self.presentOnRootController(controller)
    }
    
    @objc private func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        let captchaController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        self.presentOnRootController(captchaController)
    }
    
    @objc private func presentOnRootController(controller: UIViewController) {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
    }
}

