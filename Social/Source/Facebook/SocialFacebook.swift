import UIKit

//import FBSDKCoreKit
//import FBSDKLoginKit

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
    
    public class func setup() {
    }
}

extension FacebookNetwork: SocialNetwork {
    
    public class func name() -> String {
        return "Facebook"
    }
    
    public class func isAuthorized() -> Bool {
        return FBSDKAccessToken.currentAccessToken() != nil
    }
    
    public class func authorization(completion: SocialNetworkSignInCompletionHandler?) {
        if self.isAuthorized() == true {
            completion?(success: true, error: nil)
        } else {
            self.openNewSession(completion)
        }
    }
    
    public class func logout(completion: SocialNetworkSignOutCompletionHandler?) {
        if self.isAuthorized() == true {
            FBSDKLoginManager().logOut()
        }
        completion?()
    }
    
    private class func openNewSession(completion: SocialNetworkSignInCompletionHandler?) {
        
        let manager = FBSDKLoginManager.init()
        manager.logInWithPublishPermissions(["publish_actions"], fromViewController: nil) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            completion?(success: result.isCancelled == false && error == nil, error: error)
        }
    }
}


