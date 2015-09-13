import UIKit


//MARK: - SocialData
protocol SocialData {
    var text: String? {get}
}

//MARK: - SocialImage
typealias SocialImageRepresentationHandler = (image: UIImage) -> NSData
final class SocialImage {
    let image: UIImage
    let representationHandler: SocialImageRepresentationHandler
    
    init (image: UIImage, representationHandler: SocialImageRepresentationHandler) {
        self.image = image
        self.representationHandler = representationHandler
    }
}


//MARK: - PostToWallAction
protocol PostToWallAction {
    
    func postDataToWall<T: AnyObject where T: SocialData>(socialData: T, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) -> SocialOperation
    
    func postDataToWall(text: String, image: UIImage?, url: NSURL?, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) -> SocialOperation
}