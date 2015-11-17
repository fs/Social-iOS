import UIKit


//MARK: - FacebookSocialData and metadata
final class FacebookImageLink {
    var pictureToURL: NSURL
    var name: String?
    var description: String?
    
    init (pictureToURL: NSURL) {
        self.pictureToURL = pictureToURL
    }
}


final class FacebookSocialData: SocialData {
    var text: String?
    var url: NSURL?
    var imageLink: FacebookImageLink? {
        willSet(newValue) {
            if newValue != nil {
                self.image = nil
            }
        }
    }
    var image: SocialImage? {
        willSet(newValue) {
            if newValue != nil {
                self.imageLink = nil
            }
        }
    }
}


//MARK: - FacebookNetwork
final class FacebookNetwork: NSObject {
    
    override init() {
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
    
    class func name() -> String {
        return "Facebook"
    }
    
    class func isAuthorized() -> Bool {
        return FBSession.activeSession().isOpen
    }
    
    class func authorization(completion: ((success: Bool, error: NSError?) -> Void)?) {
        if self.isAuthorized() == true {
            completion?(success: true, error: nil)
        } else {
            self.openNewSession(completion)
        }
    }
    
    class func logout() {
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


