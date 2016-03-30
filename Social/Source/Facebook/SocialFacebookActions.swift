import UIKit

extension FacebookNetwork: PostToWallAction {
    
    public func postDataToWall(socialData: SocialData, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) -> SocialOperation {
        
        guard let facebookSocialData = socialData as? FacebookSocialData else {
            fatalError("\(socialData) must be member of FacebookSocialData class")
        }
        
        let operation = FacebookPostToWallOperation.init(socialData: facebookSocialData, completion: completion, failure: failure)
        SocialNetworkManager.sharedManager.addOperation(operation)
        return operation
    }
    
    public func postDataToWall(text: String, image: UIImage?, url: NSURL?, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) -> SocialOperation {
        
        let facebookSocialData = FacebookSocialData()
        facebookSocialData.text = text
        facebookSocialData.url = url
        
        if let lImage = image {
            let facebookImage = SocialImage.init(image: lImage, representationHandler: { (image) -> NSData in
                return UIImageJPEGRepresentation(image, 1.0)!
            })
            facebookSocialData.image = facebookImage
        }
        
        return self.postDataToWall(facebookSocialData, completion: completion, failure: failure)
    }
}

//MARK: - FacebookPostToWallOperation
public final class FacebookPostToWallOperation : SocialOperation {
    
    public let socialData: FacebookSocialData
    
    private weak var connection: FBSDKGraphRequestConnection?
    
    @available(*, unavailable, message = "init(completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) is unavailable, use init(socialData: FacebookSocialData, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock)")
    override internal init(completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) {
        fatalError("It doesn't work")
    }
    
    public init(socialData: FacebookSocialData, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) {
        self.socialData = socialData
        super.init(completion: completion, failure: failure)
    }
    
    override public func main() {
        
        if FacebookNetwork.isAuthorized {
            
            self.setSendingState()
            
            let semaphore      = dispatch_semaphore_create(0)
            let data            = self.socialData
            var graphPath       = "me/feed"
            
            var params: Dictionary<String, AnyObject> = Dictionary()
            
            if let message = data.text where data.image == nil {
                params["message"] = message
            }
            
            if let link = data.imageLink {
                
                params["picture"] = link.pictureToURL.absoluteString
                
                if let urlAsString = data.url?.absoluteString {
                    params["link"] = urlAsString
                }
                
                if let name = link.name {
                    params["name"] = name
                }
                
                if let description = link.description {
                    params["description"] = description
                }
                
            } else {
                if let urlAsString = data.url?.absoluteString {
                    params["link"] = urlAsString
                }
            }
            
            if let facebookImage = data.image {
                //It is necessary to update the orientation of image. Otherwise the picture is sent inverted
                let maxSizeImage = CGSizeMake(5120, 5120)
                var image = facebookImage.image
                if image.size.width > maxSizeImage.width || image.size.height > maxSizeImage.height {
                    image = image.social_resizeProportionalRelativelyBigSide(maxSizeImage)
                } else {
                    //rotate image
                    image = image.social_resize(image.size)
                }
                let imageData     = facebookImage.representationHandler(image: image)
                params["picture"] = imageData
                graphPath         = "me/photos"
                
                if let caption = data.text {
                    params["caption"] = caption
                }
            }
            
            dispatch_sync(dispatch_get_main_queue(), {[weak self] () -> Void in
                
                guard let sself = self else { return }
                
                let request = FBSDKGraphRequest.init(graphPath: graphPath, parameters: params, HTTPMethod: "POST")
                sself.connection = request.startWithCompletionHandler({[weak self] (requestConnection, result, error) -> Void in
                    
                    guard let sself = self else { return }
                    let success = (error == nil)
                    if success {
                        sself.setSuccessedState(result)
                    } else if sself.state != .Cancelled {
                        sself.setFailedState(error)
                    }
                    
                    dispatch_semaphore_signal(semaphore)
                    })
                })
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        } else {
            self.setFailedState(NSError.userNotAuthorizedError())
        }
    }
    
    override public func cancel() {
        self.connection?.cancel()
        super.cancel()
    }
}
