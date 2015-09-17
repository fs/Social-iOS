import Foundation

extension VKNetwork: PostToWallAction {
    
    func postDataToWall<T: AnyObject where T: SocialData>(socialData: T, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) -> SocialOperation {
        
        if let vkSocialData = socialData as? VKSocialData {
            let operation = VKPostToWallOperation(socialData: vkSocialData, completion: completion, failure: failure)
            SocialNetworkManager.sharedManager().addOperation(operation)
            return operation
        } else {
            fatalError("\(socialData) must be member of VKSocialData class")
        }
    }
    
    func postDataToWall(text: String, image: UIImage?, url: NSURL?, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) -> SocialOperation {
        
        let vkSocialData = VKSocialData()
        vkSocialData.text = text
        vkSocialData.url = url
        
        if let lImage = image {
            let vkImage = VKImage(image: lImage, parameters: VKImageParameters.jpegImageWithQuality(1.0))
            vkSocialData.image = vkImage
        }
        
        return self.postDataToWall(vkSocialData, completion: completion, failure: failure)
    }
}

//MARK: -
final class VKPostToWallOperation : SocialOperation {
    
    let socialData: VKSocialData
    
    private weak var request: VKRequest?
    
    @available(*, unavailable, message = "init(completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) is unavailable, use init(socialData: TwitterSocialData, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock)")
    override init(completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) {
        fatalError("It doesn't work")
    }
    
    init(socialData: VKSocialData, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) {
        self.socialData = socialData
        super.init(completion: completion, failure: failure)
    }
    
    override func main() {
        if VKNetwork.isAuthorized() {
            
            self.setSendingState()
            
            let socialData = self.socialData
            let semaphore = dispatch_semaphore_create(0)
            
            let postToWallHandler = {[weak self] (photos: [VKPhoto]?) -> Void in
                    
                self?.request = VKPostToWallOperation.postToWall(socialData.text, url: socialData.url, photos: photos, completion: {[weak self] (result, error) -> Void in
                    
                    if let sself = self {
                        let success = (error == nil)
                        if success == true {
                            sself.setSuccessedState(result)
                        } else {
                            sself.setFailedState(error)
                        }
                    }
                    dispatch_semaphore_signal(semaphore)
                })
            }
            
            if let image = self.socialData.image {
                self.request = VKPostToWallOperation.uploadImage(image, completion: {[weak self] (photos, error) -> Void in
                    
                    let success = (error == nil)
                    if success {
                        postToWallHandler(photos)
                    } else {
                        if let sself = self where sself.state != .Cancelled {
                            sself.setFailedState(error)
                        }
                        dispatch_semaphore_signal(semaphore)
                    }
                })
            } else {
                postToWallHandler(nil)
            }
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
        } else {
            self.setFailedState(NSError.userNotAuthorizedError())
        }
    }
    
    override func cancel() {
        self.request?.cancel()
        super.cancel()
    }
}

extension VKPostToWallOperation {
    
    class func uploadImage(vkImage: VKImage, completion:((photos: [VKPhoto]?, error: NSError?) -> Void)?) -> VKRequest? {

        let maxSizeImage = CGSizeMake(2560, 2048)
        var image = vkImage.image
        if image.size.width > maxSizeImage.width || image.size.height > maxSizeImage.height {
            image = image.social_resizeProportionalRelativelyBigSide(maxSizeImage)
        } else {
            //rotate image
            image = image.social_resize(image.size)
        }
        
        let request = VKApi.uploadWallPhotoRequest(image, parameters: vkImage.parameters, userId: Int(VKSdk.getAccessToken().userId)!, groupId: 0)
        
        request.executeWithResultBlock({ (respone: VKResponse!) -> Void in
            
            let photos: [VKPhoto] = [(respone.parsedModel as! VKPhotoArray).firstObject() as! VKPhoto]
            completion?(photos: photos, error: nil)
            
        }, errorBlock: { (error: NSError!) -> Void in
            
            completion?(photos: nil, error: error)
        })
        
        return request
    }
    
    class func postToWall(message: String?, url: NSURL?, photos: [VKPhoto]?, completion:((result: AnyObject?, error: NSError?) -> Void)?) -> VKRequest? {
        var attachments: [String] = []
        if let photos = photos {
            for photo in photos {
                let description = "photo\(photo.owner_id)_\(photo.id)"
                attachments.append(description)
            }
        }
        
        if let lUrlAsString = url?.absoluteString {
            attachments.append(lUrlAsString)
        }
        
        var params: Dictionary<String, AnyObject> = ["attachments" : attachments.joinWithSeparator(",")]
        if let lMessage = message {
            params["message"] = lMessage
        }
        
        let request = VKApi.wall().post(params)
        
        request.executeWithResultBlock({ (response: VKResponse!) -> Void in
            
            completion?(result: response.parsedModel, error: nil)
            
            }, errorBlock: { (error: NSError!) -> Void in
                
                completion?(result: nil, error: error)
        })
        
        return request
    }
}