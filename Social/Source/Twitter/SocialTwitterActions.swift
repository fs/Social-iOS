import UIKit

extension TwitterNetwork: PostToWallAction {

    public func postDataToWall(socialData: SocialData, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) -> SocialOperation {

        if let twitterSocialData = socialData as? TwitterSocialData {
            let operation = TwitterPostToWallOperation(socialData: twitterSocialData, completion: completion, failure: failure)
            SocialNetworkManager.sharedManager().addOperation(operation)
            return operation
        } else {
            fatalError("\(socialData) must be member of TwitterSocialData class")
        }
    }

    public func postDataToWall(text: String, image: UIImage?, url: NSURL?, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) -> SocialOperation {

        let twitterSocialData = TwitterSocialData()
        twitterSocialData.text = text
        twitterSocialData.url = url

        if let lImage = image {
            let twitterImage = SocialImage(image: lImage) { (image) -> NSData in
                return UIImageJPEGRepresentation(image, 1.0)!
            }
            twitterSocialData.image = twitterImage
        }

        return self.postDataToWall(twitterSocialData, completion: completion, failure: failure)
    }
}

//MARK: -
public final class TwitterPostToWallOperation : SocialOperation {

    public let socialData: TwitterSocialData

    @available(*, unavailable, message = "init(completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) is unavailable, use init(socialData: TwitterSocialData, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock)")
    override internal init(completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) {
        fatalError("It doesn't work")
    }

    public init(socialData: TwitterSocialData, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) {
        self.socialData = socialData
        super.init(completion: completion, failure: failure)
    }

    override public func main() {
        
        if TwitterNetwork.isAuthorized() {
            
            self.setSendingState()

            let socialData = self.socialData
            let semaphore = dispatch_semaphore_create(0)

            let updateStatusHandler = {(imagesIDs: [String]?) -> Void in

                TwitterPostToWallOperation.updateStatus(socialData.text, url: socialData.url, imagesIDs: imagesIDs, completion: {[weak self] (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in

                    if let sself = self {
                        let success = (error == nil)
                        if let data = data where success == true {

                            do {
                                let result = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! Dictionary<String, AnyObject>
                                sself.setSuccessedState(result)
                            } catch let jsonError as NSError {
                                sself.setFailedState(jsonError)
                            }
                        } else if sself.state != .Cancelled {
                            sself.setFailedState(error)
                        }
                    }

                    dispatch_semaphore_signal(semaphore)
                })
            }

            if let twitterImage = socialData.image {
                TwitterPostToWallOperation.uploadImage(twitterImage, completion: {[weak self] (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in

                    if let sself = self {

                        let success = (error == nil)
                        if let data = data where success == true {

                            do {
                                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! Dictionary<String, AnyObject>

                                var imagesIDs: [String] = []
                                if let media_id_string = json["media_id_string"] as? String  {
                                    imagesIDs.append(media_id_string)
                                }
                                updateStatusHandler(imagesIDs)
                            } catch let jsonError as NSError {
                                sself.setFailedState(jsonError)
                                dispatch_semaphore_signal(semaphore)
                            }

                        } else if sself.state != .Cancelled {
                            sself.setFailedState(error)
                            dispatch_semaphore_signal(semaphore)
                        }
                    }
                })
            } else {
                updateStatusHandler(nil)
            }

            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        } else {
            self.setFailedState(NSError.userNotAuthorizedError())
        }
    }

    override public func cancel() {
        print("Twitter SDK don't support canceling operations")
    }
}

public extension TwitterPostToWallOperation {

    public class func uploadImage(twitterImage: SocialImage, completion:TWTRNetworkCompletion) {
        
        guard let twAPIClient = TwitterNetwork.getAPIClient() else {
            completion(nil, nil, NSError.tw_getAPIClientError())
            return
        }
        
        let maxSizeImage = CGSizeMake(1024, 1024)
        var image = twitterImage.image
        if image.size.width > maxSizeImage.width || image.size.height > maxSizeImage.height {
            image = image.social_resizeProportionalRelativelyBigSide(maxSizeImage)
        } else {
            //rotate image
            image = image.social_resize(image.size)
        }

        let strUploadUrl                = "https://upload.twitter.com/1.1/media/upload.json"
        
        var error: NSError?             = nil
        var parameters                  = Dictionary<String, AnyObject>()
        let imageData                   = twitterImage.representationHandler(image: image)

        assert(imageData.length <= 3 * 1024 * 1024 /*3 mb max size of a image*/, "Max size of \(twitterImage.image) more 3 mb")

        parameters["media"]             = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)

        let twUploadRequest = twAPIClient.URLRequestWithMethod("POST", URL: strUploadUrl, parameters: parameters, error: &error)
        twAPIClient.sendTwitterRequest(twUploadRequest, completion: completion)
    }

    public class func updateStatus(status: String? = "", url: NSURL?, imagesIDs: [String]?, completion:TWTRNetworkCompletion) {
        
        guard let twAPIClient = TwitterNetwork.getAPIClient() else {
            completion(nil, nil, NSError.tw_getAPIClientError())
            return
        }
        
        let strStatusUrl            = "https://api.twitter.com/1.1/statuses/update.json"
        var error: NSError?         = nil
        var parameters              = Dictionary<String, AnyObject>()

        var message = ""
        if let lStatus = status {
            message += lStatus
        }

        if let url = url?.absoluteString {
            message += "\n\(url)"
        }

        let tweetLength = TwitterText.tweetLength(message)
        assert(tweetLength <= 140, "Too long the message for Twitter. Max length 140 symbols but it is \(tweetLength) length. \r\n \(message)")

        parameters["status"]        = message
        parameters["trim_user"]     = "true"

        if let imagesIDs = imagesIDs {
            parameters["media_ids"] = imagesIDs.joinWithSeparator(",")
        }

        let twStatusRequest = twAPIClient.URLRequestWithMethod("POST", URL: strStatusUrl, parameters: parameters, error: &error)
        twAPIClient.sendTwitterRequest(twStatusRequest, completion: completion)
    }
}