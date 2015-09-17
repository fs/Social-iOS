//
//  SocialHelper.swift
//  Social
//
//  Created by Vladimir Goncharov on 17.09.15.
//  Copyright © 2015 FlatStack. All rights reserved.
//

import UIKit

//MARK: - Helpers
func social_performInMainThreadSync(action:(() -> Void)) {
    if NSThread.isMainThread() {
        action()
    } else {
        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
            action()
        })
    }
}


