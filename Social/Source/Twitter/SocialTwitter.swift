import UIKit

//MARK: - TwitterSocialData and metadata
final class TwitterSocialData: SocialData {
    var text: String?
    var url: NSURL? {
        willSet(newValue) {
            if newValue != nil {
                self.image = nil
            }
        }
    }
    var image: SocialImage? {
        willSet(newValue) {
            if newValue != nil {
                self.url = nil
            }
        }
    }
}

//MARK: - TwitterNetwork
class TwitterNetwork: NSObject {
    
    override init() {
        super.init()
        
        //init session
        Twitter.sharedInstance()
    }
}

//MARK: - SocialNetwork
extension TwitterNetwork: SocialNetwork {
    
    class func name() -> String {
        return "Twitter"
    }
    
    class func isAuthorized() -> Bool {
        let isAuthorized = {() -> AnyObject? in
            return (Twitter.sharedInstance().sessionStore.session() != nil)
        }

        return self.tw_performInMainThread(isAuthorized) as! Bool
    }
    
    class func authorization(completion: ((success: Bool, error: NSError?) -> Void)?) {
        if (self.isAuthorized()) {
            completion?(success: true, error: nil)
        } else {
            self.openNewSession(completion)
        }
    }
    
    private class func openNewSession(completion: ((success: Bool, error: NSError?) -> Void)?) {
        let openSession = {() -> AnyObject? in
            
            Twitter.sharedInstance().logInWithCompletion({ (session, error) -> Void in
                completion?(success: error == nil, error: error)
            })
            
            return nil
        }
        
        self.tw_performInMainThread(openSession)
    }
    
    class func logout() {
        if self.isAuthorized() == true {
            let logout = {() -> AnyObject? in
                Twitter.sharedInstance().logOut()
                
                return nil
            }
            
            self.tw_performInMainThread(logout)
        }
    }
}

//MARK: -
extension TwitterNetwork {
    
    internal class func getAPIClient() -> TWTRAPIClient? {
        
        let getAPIClient = {() -> AnyObject? in
            return TWTRAPIClient.init(userID: Twitter.sharedInstance().sessionStore.session()?.userID)
        }
        
        return TwitterNetwork.tw_performInMainThread(getAPIClient) as? TWTRAPIClient
    }
    
    internal class func tw_performInMainThread(action:(() -> AnyObject?)) -> AnyObject? {
        var result: AnyObject? = nil
        if NSThread.isMainThread() {
            result = action()
        } else {
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                result = action()
            })
        }
        
        return result
    }
}

//MARK: -
extension NSError {
    internal class func tw_getAPIClientError() -> NSError {
        
        return NSError.init(domain: "com.TwitterNetwork", code: -100, userInfo: [NSLocalizedDescriptionKey : "API client can not initialization"])
    }
}
