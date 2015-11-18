import UIKit


//MARK: - SocialNetworkManager
private let SharedSocialNetworkManager = SocialNetworkManager()
public class SocialNetworkManager : NSOperationQueue {
    
    public class func sharedManager() -> SocialNetworkManager {
        return SharedSocialNetworkManager
    }
    
    override public init() {
        super.init()
        self.name = "com.Social.SocialNetworkManager"
        self.maxConcurrentOperationCount = 5
    }
}