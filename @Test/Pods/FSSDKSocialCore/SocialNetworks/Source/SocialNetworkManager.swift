import UIKit

public class SocialNetworkManager : NSOperationQueue {
    
    public class var sharedManager: SocialNetworkManager {
        struct Static {
            static var instance: SocialNetworkManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = SocialNetworkManager()
        }
        
        return Static.instance!
    }

    private override init() {
        super.init()
        self.name = "com.Social.SocialNetworkManager"
        self.maxConcurrentOperationCount = 5
    }
}