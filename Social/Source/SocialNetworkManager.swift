import UIKit


//MARK: - SocialNetworkManager
private let SharedSocialNetworkManager = SocialNetworkManager()
class SocialNetworkManager : NSOperationQueue {
    
    class func sharedManager() -> SocialNetworkManager {
        return SharedSocialNetworkManager
    }
    
    override init() {
        super.init()
        self.name = "com.Social.SocialNetworkManager"
        self.maxConcurrentOperationCount = 5
    }
}