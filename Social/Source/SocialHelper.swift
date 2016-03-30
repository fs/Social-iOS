import UIKit

//MARK: - Helpers
internal func social_performInMainThreadSync(action:(() -> Void)) {
    if NSThread.isMainThread() {
        action()
    } else {
        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
            action()
        })
    }
}


