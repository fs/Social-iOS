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
    
}

extension FacebookNetwork: SocialNetwork {
    
    public class func name() -> String {
        return "Facebook"
    }
    
    public class func isAuthorized() -> Bool {
        return FBSDKAccessToken.currentAccessToken() != nil
    }
    
    public class func authorization(completion: ((success: Bool, error: NSError?) -> Void)?) {
        if self.isAuthorized() == true {
            completion?(success: true, error: nil)
        } else {
            self.openNewSession(completion)
        }
    }
    
    public class func logout() {
        if self.isAuthorized() == true {
            FBSDKLoginManager().logOut()
        }
    }
    
    private class func openNewSession(completion: ((success: Bool, error: NSError?) -> Void)?) {
        
        let manager = FBSDKLoginManager.init()
        manager.logInWithPublishPermissions(["publish_actions"]) { (result, error) -> Void in
            completion?(success: error == nil, error: error)
        }
    }
}


