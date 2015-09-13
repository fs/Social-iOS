import UIKit

//MARK: - VKSocialData and metadata
final class VKImage {
    let image: UIImage
    let parameters: VKImageParameters
    
    init (image: UIImage, parameters: VKImageParameters) {
        self.image = image
        self.parameters = parameters
    }
}

final class VKSocialData: SocialData {
    var text: String?
    var url: NSURL? {
        willSet(newValue) {
            if newValue != nil {
                self.image = nil
            }
        }
    }
    var image: VKImage? {
        willSet(newValue) {
            if newValue != nil {
                self.url = nil
            }
        }
    }
}

//MARK: - VKNetwork

//Notifications need send in VKSDK delegate
let kVKDidUpdateTokenNotification = "__kVKDidUpdateTokenNotification__"
let kVKDeniedAccessNotification = "__kVKDeniedAccessNotification__"
let kVKHasExperiedTokenNotification = "__kVKHasExperiedTokenNotification__"

class VKNetwork: NSObject {
    
    override init() {
        super.init()
        
        //init session
        VKSdk.wakeUpSession()
    }
}

//MARK:-
extension VKNetwork: SocialNetwork {
    
    class func name() -> String {
        return "VK"
    }
    
    class func isAuthorized() -> Bool {
        return VKSdk.isLoggedIn()
    }
    
    class func authorization(completion: ((success: Bool, error: NSError?) -> Void)?) {
        if (self.isAuthorized()) {
            if let completion = completion {
                completion(success: true, error: nil)
            }
        } else {
            self.openNewSession(completion)
        }
    }
    
    class func logout() {
        if self.isAuthorized() == true {
            VKSdk.forceLogout()
        }
    }
    
    private class func openNewSession(completion: ((success: Bool, error: NSError?) -> Void)?) {
        VKSdk.authorize(["photos", "wall"])
        
        NSNotificationCenter.defaultCenter().addObserverForName(kVKDidUpdateTokenNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notif: NSNotification!) -> Void in
            
            completion?(success: true, error: nil)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(kVKDeniedAccessNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notif: NSNotification!) -> Void in
            
            completion?(success: false, error: nil)
        }
    }
}
