import UIKit

#if FACE
    
#endif
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
    
    override public init() {
        super.init()
        
        //init session
        let state = FBSession.activeSession().state
        switch state
        {
        case .CreatedTokenLoaded, .CreatedOpening:
            FacebookNetwork.openNewSession(nil)
            
        default:
            break
        }
    }
}

extension FacebookNetwork: SocialNetwork {
    
    public class func name() -> String {
        return "Facebook"
    }
    
    public class func isAuthorized() -> Bool {
        return FBSession.activeSession().isOpen
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
            FBSession.activeSession().closeAndClearTokenInformation()
        }
    }
    
    private class func openNewSession(completion: ((success: Bool, error: NSError?) -> Void)?) {
        
        let session = FBSession(permissions: ["email", "public_profile", "publish_actions"])
        FBSession.setActiveSession(session)
        session.openWithCompletionHandler { (session, status, error) -> Void in
            switch status
            {
            case .Open, .OpenTokenExtended:
                completion?(success: true, error: nil)
                
            default:
                completion?(success: false, error: error)
            }
        }
    }
}


