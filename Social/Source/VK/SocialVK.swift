import UIKit

//import VK_ios_sdk

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
private let VKPermisions = ["photos", "wall", "email"]

private let defaultDelegate = VKNetworkDelegate.init()
private let uiDefaultDelegate = VKNetworkUIDelegate.init()

public class VKNetwork: NSObject {
    
    public class func setup() {
        if VKSdk.instance().uiDelegate == nil {
            self.setDefaultUIDelegate()
        }
        VKSdk.instance().registerDelegate(defaultDelegate)
        VKSdk.wakeUpSession(VKPermisions) { (state, error) -> Void in
            if let lError = error {
                debugPrint("\(__FUNCTION__) - is received error \(lError)")
            } else {
                debugPrint("\(__FUNCTION__) - is updated state \(state.rawValue)")
            }
        }
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
    
    public class func name() -> String {
        return "VK"
    }
    
    public class func isAuthorized() -> Bool {
        return VKSdk.isLoggedIn()
    }
    
    public class func authorization(completion: SocialNetworkSignInCompletionHandler?) {
        if (self.isAuthorized()) {
            completion?(success: true, error: nil)
        } else {
            self.openNewSession(completion)
        }
    }
    
    public class func logout(completion: SocialNetworkSignOutCompletionHandler?) {
        if self.isAuthorized() == true {
            VKSdk.forceLogout()
        }
        completion?()
    }
    
    private class func openNewSession(completion: SocialNetworkSignInCompletionHandler?) {
        VKSdk.authorize(VKPermisions)
        
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

