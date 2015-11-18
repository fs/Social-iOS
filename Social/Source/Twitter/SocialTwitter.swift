import UIKit

//MARK: - TwitterSocialData and metadata
public final class TwitterSocialData: SocialData {
    public var text: String?
    public var url: NSURL? {
        willSet(newValue) {
            if newValue != nil {
                self.image = nil
            }
        }
    }
    public var image: SocialImage? {
        willSet(newValue) {
            if newValue != nil {
                self.url = nil
            }
        }
    }
}

//MARK: - TwitterNetwork
public class TwitterNetwork: NSObject {
    
    override public init() {
        super.init()
        
        //init session
        Twitter.sharedInstance()
    }
}

//MARK: - SocialNetwork
extension TwitterNetwork: SocialNetwork {
    
    public class func name() -> String {
        return "Twitter"
    }
    
    public class func isAuthorized() -> Bool {
        let isAuthorized = {() -> AnyObject? in
            return (Twitter.sharedInstance().sessionStore.session() != nil)
        }

        return self.tw_performInMainThread(isAuthorized) as! Bool
    }
    
    public class func authorization(completion: ((success: Bool, error: NSError?) -> Void)?) {
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
    
    public class func logout() {
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
public extension TwitterNetwork {
    
    public class func getAPIClient() -> TWTRAPIClient? {
        
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
internal extension NSError {
    
    internal class func tw_getAPIClientError() -> NSError {
        return NSError.init(domain: "com.TwitterNetwork", code: -100, userInfo: [NSLocalizedDescriptionKey : "API client can not initialization"])
    }
}
