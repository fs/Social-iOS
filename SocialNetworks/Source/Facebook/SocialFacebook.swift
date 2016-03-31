import UIKit

//MARK: - FacebookSocialData and metadata
public final class FacebookImageLink {
    public var pictureToURL: NSURL
    public var name: String?
    public var description: String?
    
    public init (pictureToURL: NSURL) {
        self.pictureToURL = pictureToURL
    }
}


public final class FacebookSocialData: SocialData {
    public var text: String?
    public var url: NSURL?
    public var imageLink: FacebookImageLink? {
        willSet(newValue) {
            if newValue != nil {
                self.image = nil
            }
        }
    }
    public var image: SocialImage? {
        willSet(newValue) {
            if newValue != nil {
                self.imageLink = nil
            }
        }
    }
}


//MARK: - FacebookNetwork
public final class FacebookNetwork: NSObject {
    
    public static var permissions: [String] = ["publish_actions"]
    
    public class var shared: FacebookNetwork {
        struct Static {
            static var instance: FacebookNetwork?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = FacebookNetwork()
        }
        
        return Static.instance!
    }
    
    private override init() {
        super.init()
    }
}

extension FacebookNetwork: SocialNetwork {
    
    public class var name: String {
        return "Facebook"
    }
    
    public class var isAuthorized: Bool {
        return FBSDKAccessToken.currentAccessToken() != nil
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
            FBSDKLoginManager().logOut()
        }
        completion?()
    }
    
    private class func openNewSession(completion: SocialNetworkSignInCompletionHandler?) {
        
        let manager = FBSDKLoginManager.init()
        manager.logInWithPublishPermissions(FacebookNetwork.permissions, fromViewController: nil) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            completion?(success: result.isCancelled == false && error == nil, error: error)
        }
    }
}


