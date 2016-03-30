import UIKit

//MARK: - VKSocialData and metadata
public final class VKImage {
    public let image: UIImage
    public let parameters: VKImageParameters
    
    public init (image: UIImage, parameters: VKImageParameters) {
        self.image = image
        self.parameters = parameters
    }
}

public final class VKSocialData: SocialData {
    public var text: String?
    public var url: NSURL?
    public var image: VKImage?
}

//MARK: - VKNetwork
private let VKPermisions = ["photos", "wall"]

public class VKNetwork: NSObject {
    
    override public init() {
        super.init()
        
        //init session
        if VKSdk.instance().uiDelegate == nil {
            VKSdk.instance().uiDelegate = self
        }
        VKSdk.instance().registerDelegate(self)
        VKSdk.wakeUpSession(VKPermisions) { (state, error) -> Void in
            if let lError = error {
                debugPrint("\(#function) - is received error \(lError)")
            } else {
                debugPrint("\(#function) - is updated state \(state.rawValue)")
            }
        }
    }
}

//MARK:-
extension VKNetwork: SocialNetwork {
    
    public class func name() -> String {
        return "VK"
    }
    
    public class func isAuthorized() -> Bool {
        return VKSdk.isLoggedIn()
    }
    
    public class func authorization(completion: ((success: Bool, error: NSError?) -> Void)?) {
        if (self.isAuthorized()) {
            completion?(success: true, error: nil)
        } else {
            self.openNewSession(completion)
        }
    }
    
    public class func logout() {
        if self.isAuthorized() == true {
            VKSdk.forceLogout()
        }
    }
    
    private class func openNewSession(completion: ((success: Bool, error: NSError?) -> Void)?) {
        VKSdk.authorize(VKPermisions)
        
        NSNotificationCenter.defaultCenter().addObserverForName(VKNetworkNotificationDidUpdateToken, object: nil, queue: NSOperationQueue.mainQueue()) { (notif: NSNotification!) -> Void in
            social_performInMainThreadSync({ () -> Void in
                completion?(success: true, error: nil)
            })
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(VKNetworkNotificationDeniedAccess, object: nil, queue: NSOperationQueue.mainQueue()) { (notif: NSNotification!) -> Void in
            social_performInMainThreadSync({ () -> Void in
                completion?(success: false, error: nil)
            })
        }
    }
}


//MARK: -
//Notifications
private let VKNetworkNotificationDidUpdateToken     = "__kVKDidUpdateTokenNotification__"
private let VKNetworkNotificationDeniedAccess       = "__kVKDeniedAccessNotification__"
private let VKNetworkNotificationHasExperiedToken   = "__kVKHasExperiedTokenNotification__"

extension VKNetwork: VKSdkDelegate {
    public func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
        if let token = result?.token where result?.user != nil {
            social_performInMainThreadSync({ () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(VKNetworkNotificationDidUpdateToken, object: token)
            })
        } else {
            social_performInMainThreadSync({ () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(VKNetworkNotificationDeniedAccess, object: result?.error)
            })
        }
    }
    
    public func vkSdkAccessTokenUpdated(newToken: VKAccessToken!, oldToken: VKAccessToken!) {
        social_performInMainThreadSync({ () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(VKNetworkNotificationDidUpdateToken, object: newToken)
        })
    }
    
    public func vkSdkUserAuthorizationFailed() {
        social_performInMainThreadSync({ () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(VKNetworkNotificationDeniedAccess, object: nil)
        })
    }
    
    public func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        social_performInMainThreadSync({ () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(VKNetworkNotificationHasExperiedToken, object: expiredToken)
        })
    }
}

//MARK: -
extension VKNetwork: VKSdkUIDelegate {
    
    public func vkSdkShouldPresentViewController(controller: UIViewController!) {
        self.presentOnRootController(controller)
    }
    
    public func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        let captchaController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        self.presentOnRootController(captchaController)
    }
    
    private func presentOnRootController(controller: UIViewController) {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
    }
}

