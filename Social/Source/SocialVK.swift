import UIKit

//MARK: - VKSocialData and metadata
final class VKImage {
    let image: UIImage
    let parameters: VKImageParameters
    
    init (image: UIImage, parameters: VKImageParameters) {
        self.image = image
        self.parameters = parameters
    }
}

final class VKSocialData: SocialData {
    var text: String?
    var url: NSURL? {
        willSet(newValue) {
            if newValue != nil {
                self.image = nil
            }
        }
    }
    var image: VKImage? {
        willSet(newValue) {
            if newValue != nil {
                self.url = nil
            }
        }
    }
}

//MARK: - VKNetwork
private let VKPermisions = ["photos", "wall"]

class VKNetwork: NSObject {
    
    override init() {
        super.init()
        
        //init session
        if VKSdk.instance().uiDelegate == nil {
            VKSdk.instance().uiDelegate = self
        }
        VKSdk.instance().registerDelegate(self)
        VKSdk.wakeUpSession(VKPermisions) { (state, error) -> Void in
            if let lError = error {
                debugPrint("\(__FUNCTION__) - is received error \(lError)")
            } else {
                debugPrint("\(__FUNCTION__) - is updated state \(state.rawValue)")
            }
        }
    }
}

//MARK:-
extension VKNetwork: SocialNetwork {
    
    class func name() -> String {
        return "VK"
    }
    
    class func isAuthorized() -> Bool {
        return VKSdk.isLoggedIn()
    }
    
    class func authorization(completion: ((success: Bool, error: NSError?) -> Void)?) {
        if (self.isAuthorized()) {
            completion?(success: true, error: nil)
        } else {
            self.openNewSession(completion)
        }
    }
    
    class func logout() {
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
let VKNetworkNotificationDidUpdateToken     = "__kVKDidUpdateTokenNotification__"
let VKNetworkNotificationDeniedAccess       = "__kVKDeniedAccessNotification__"
let VKNetworkNotificationHasExperiedToken   = "__kVKHasExperiedTokenNotification__"

extension VKNetwork: VKSdkDelegate {
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
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
    
    func vkSdkAccessTokenUpdated(newToken: VKAccessToken!, oldToken: VKAccessToken!) {
        social_performInMainThreadSync({ () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(VKNetworkNotificationDidUpdateToken, object: newToken)
        })
    }
    
    func vkSdkUserAuthorizationFailed() {
        social_performInMainThreadSync({ () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(VKNetworkNotificationDeniedAccess, object: nil)
        })
    }
    
    func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        social_performInMainThreadSync({ () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(VKNetworkNotificationHasExperiedToken, object: expiredToken)
        })
    }
}

//MARK: -
extension VKNetwork: VKSdkUIDelegate {
    
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        self.presentOnRootController(controller)
    }
    
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        let captchaController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        self.presentOnRootController(captchaController)
    }
    
    private func presentOnRootController(controller: UIViewController) {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
    }
}

