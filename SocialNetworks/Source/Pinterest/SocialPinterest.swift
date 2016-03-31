import UIKit

public class SocialPinterest: NSObject {
    
    public static var permissions: [String] = [PDKClientReadPublicPermissions,
                                               PDKClientWritePublicPermissions]
    
    public class var shared: SocialPinterest {
        struct Static {
            static var instance: SocialPinterest?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            let instance = SocialPinterest()
            Static.instance = instance
        }
        
        return Static.instance!
    }
    
    private override init() {
        super.init()
    }
}

//MARK: -
extension SocialPinterest: SocialNetwork {
    
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
        PDKClient.sharedInstance().authenticateWithPermissions(SocialPinterest.permissions, withSuccess: { (response) in
            completion?(success: true, error: nil)
        }) { (error) in
            completion?(success: false, error: error)
        }
    }
}
