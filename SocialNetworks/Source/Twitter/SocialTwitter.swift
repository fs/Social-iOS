import UIKit

//MARK: -
private let twUserIDKey = "__twUserIDKey__"

public class TwitterNetwork: NSObject {
    
    public class var shared: TwitterNetwork {
        struct Static {
            static var instance: TwitterNetwork?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Twitter.sharedInstance()
            Static.instance = TwitterNetwork()
        }
        
        return Static.instance!
    }
    
    private override init() {
        super.init()
    }
    
    private class var currentUserID: String? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(twUserIDKey) as? String
        }
        set(newValue) {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: twUserIDKey)
        }
    }
    
    class var currentUserSession: TWTRAuthSession? {
        if let currentUserID = self.currentUserID {
            return Twitter.sharedInstance().sessionStore.sessionForUserID(currentUserID)
        }
        return nil
    }
}

//MARK: -
extension TwitterNetwork: SocialNetwork {
    
    public class var name: String {
        return "Twitter"
    }
    
    public class var isAuthorized: Bool {
        let isAuthorized = {() -> AnyObject? in
            return self.currentUserSession != nil
        }
        
        return self.tw_performInMainThread(isAuthorized) as! Bool
    }
    
    public class func authorization(completion: SocialNetworkSignInCompletionHandler?) {
        if (self.isAuthorized) {
            completion?(success: true, error: nil)
        } else {
            self.openNewSession(completion)
        }
    }
    
    private class func openNewSession(completion: SocialNetworkSignInCompletionHandler?) {
        let openSession = {() -> AnyObject? in
            
            Twitter.sharedInstance().logInWithCompletion({ (session, error) -> Void in
                if let lSession = session {
                    self.currentUserID = lSession.userID
                }
                completion?(success: error == nil, error: error)
            })
            
            return nil
        }
        
        self.tw_performInMainThread(openSession)
    }
    
    public class func logout(completion: SocialNetworkSignOutCompletionHandler?) {
        
        guard self.isAuthorized == true else {
            completion?()
            return
        }
        
        let logout = {() -> AnyObject? in
            if let session = self.currentUserSession {
                Twitter.sharedInstance().sessionStore.logOutUserID(session.userID)
            }
            
            self.currentUserID = nil
            
            //log out is async
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                completion?()
            })
            
            return nil
        }
        
        self.tw_performInMainThread(logout)
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
