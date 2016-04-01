import UIKit

public class PinterestNetwork: NSObject {
    
    public static var permissions: [String] = [PDKClientReadPublicPermissions,
                                               PDKClientWritePublicPermissions]
    public static var boardName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
    
    public class var shared: PinterestNetwork {
        struct Static {
            static var instance: PinterestNetwork?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            PDKClient.sharedInstance().silentlyAuthenticateWithSuccess(nil, andFailure: nil)
            
            let instance = PinterestNetwork()
            Static.instance = instance
        }
        
        return Static.instance!
    }
    
    private override init() {
        super.init()
    }
}

//MARK: -
extension PinterestNetwork: SocialNetwork {
    
    public class var name: String {
        return "Pinterest"
    }
    
    public class var isAuthorized: Bool {
        return PDKClient.sharedInstance().authorized
    }
    
    public class func authorization(completion: SocialNetworkSignInCompletionHandler?) {
        if self.isAuthorized == true {
            completion?(success: true, error: nil)
        } else {
            self.openNewSession(completion)
        }
    }
    
    public class func logout(completion: SocialNetworkSignOutCompletionHandler?) {
        if self.isAuthorized == true {
            PDKClient.clearAuthorizedUser()
        }
        completion?()
    }
    
    private class func openNewSession(completion: SocialNetworkSignInCompletionHandler?) {
        PDKClient.sharedInstance().authenticateWithPermissions(PinterestNetwork.permissions, withSuccess: { (response) in
            completion?(success: true, error: nil)
        }) { (error) in
            completion?(success: false, error: error)
        }
    }
}

//MARK: -
internal extension NSError {
    
    internal class func pdk_getAPIClientError() -> NSError {
        return NSError.init(domain: "com.TwitterNetwork", code: -100, userInfo: [NSLocalizedDescriptionKey : "API client can not initialization"])
    }
}
