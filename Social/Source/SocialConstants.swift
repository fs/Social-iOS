import UIKit

//MARK: - debug
func SocialDebugPrintln<T>(message: T) {
    debugPrint("(File: \(__FILE__), Function: \(__FUNCTION__), Line: \(__LINE__)) \n __DEBUG_MESSAGE: \"\(message)\"")
}

//MARK: - Erorr

let kSocialOperationNotAuthorizedErrorKey = 401

extension NSError {
    class func userNotAuthorizedError() -> NSError {
        let error = NSError(domain: "SocialOperation", code: kSocialOperationNotAuthorizedErrorKey, userInfo: nil)
        return error
    }
}
