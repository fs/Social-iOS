import UIKit

//MARK: - debug
internal func SocialDebugPrintln<T>(message: T) {
    debugPrint("(File: \(__FILE__), Function: \(__FUNCTION__), Line: \(__LINE__)) \n __DEBUG_MESSAGE: \"\(message)\"")
}

//MARK: - Erorr

public let kSocialOperationNotAuthorizedErrorKey = 401

internal extension NSError {
    internal class func userNotAuthorizedError() -> NSError {
        let error = NSError(domain: "SocialOperation", code: kSocialOperationNotAuthorizedErrorKey, userInfo: nil)
        return error
    }
}
