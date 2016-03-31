import UIKit

//MARK: - SocialData
public protocol SocialData {
    var text: String? {get}
}

//MARK: - SocialImage
public typealias SocialImageRepresentationHandler = (image: UIImage) -> NSData
public final class SocialImage {
    public let image: UIImage
    public let representationHandler: SocialImageRepresentationHandler
    
    public init (image: UIImage, representationHandler: SocialImageRepresentationHandler) {
        self.image = image
        self.representationHandler = representationHandler
    }
}


//MARK: - PostToWallAction
public protocol PostToWallAction: NSObjectProtocol {
    
    func postDataToWall(socialData: SocialData, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) -> SocialOperation
    
    func postDataToWall(text: String, image: UIImage?, url: NSURL?, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) -> SocialOperation
}