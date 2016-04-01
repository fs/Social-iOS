import UIKit

//MARK: - PISocialData and metadata
public final class PISocialData: SocialData {
    public let boardName: String
    public var text: String?
    public var url: NSURL?
    public var image: SocialImage
    
    init(boardName: String, image: SocialImage) {
        self.boardName = boardName
        self.image = image
    }
}

//MARK: -
extension PinterestNetwork: PostToWallAction {
    
    public func postDataToWall(socialData: SocialData, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) -> SocialOperation {
        
        if let pinterestSocialData = socialData as? PISocialData {
            let operation = PinterestToWallOperation(socialData: pinterestSocialData, completion: completion, failure: failure)
            SocialNetworkManager.sharedManager.addOperation(operation)
            return operation
        } else {
            fatalError("\(socialData) must be member of PISocialData class")
        }
    }
    
    public func postDataToWall(text: String, image: UIImage?, url: NSURL?, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) -> SocialOperation {
        
        guard let lImage = image else { fatalError("image can't be nil") }
        
        let boardName = PinterestNetwork.boardName
        
        let pinterestImage = SocialImage(image: lImage) { (image) -> NSData in
            return UIImageJPEGRepresentation(image, 1.0)!
        }
        
        let socialData = PISocialData(boardName: boardName, image: pinterestImage)
        socialData.text = text
        socialData.url = url
        
        return self.postDataToWall(socialData, completion: completion, failure: failure)
    }
}

//MARK: -
public final class PinterestToWallOperation : SocialOperation {
    
    public let socialData: PISocialData
    
    @available(*, unavailable, message = "init(completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) is unavailable, use init(socialData: PISocialData, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock)")
    override internal init(completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) {
        fatalError("It doesn't work")
    }
    
    public init(socialData: PISocialData, completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) {
        self.socialData = socialData
        super.init(completion: completion, failure: failure)
    }
    
    override public func main() {
        
        if PinterestNetwork.isAuthorized {
            
            self.setSendingState()
            
            let socialData = self.socialData
            let semaphore = dispatch_semaphore_create(0)
            
            PinterestToWallOperation.postToWall(socialData.boardName, message: socialData.text, url: socialData.url, image: socialData.image, completion: {[weak self] (result, error) in
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
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
        } else {
            self.setFailedState(NSError.userNotAuthorizedError())
        }
    }
    
    override public func cancel() {
        super.cancel()
        SocialDebugPrintln("\(PinterestToWallOperation.self) doesn't support cancel of the operation")
    }
}

public extension PinterestToWallOperation {
    
    class public func postToWall(boardName: String, message: String?, url: NSURL?, image: SocialImage, completion:((result: AnyObject?, error: NSError?) -> Void)?) {
        
        let sendPin = {(board: PDKBoard) -> Void in
            PDKClient.sharedInstance().createPinWithImage(image.image, link: url, onBoard: board.identifier, description: message, progress: nil, withSuccess: { (response) in
                completion?(result: response, error: nil)
            }) { (error) in
                completion?(result: nil, error: error)
            }
        }
        
        PDKClient.sharedInstance().getAuthenticatedUserBoardsWithFields(Set(arrayLiteral: "id", "name"), success: { (response) in
            let boards = response.boards() as! [PDKBoard]
            var board: PDKBoard? = nil
            for currentBoard in boards {
                if currentBoard.name == PinterestNetwork.boardName {
                    board = currentBoard
                    break
                }
            }
            
            if let lBoard = board {
                PDKClient.sharedInstance().getBoardWithIdentifier(lBoard.identifier, fields: Set(arrayLiteral: "id"), withSuccess: { (response) in
                    sendPin(response.board())
                }) { (error) in
                    completion?(result: nil, error: error)
                }
            } else {
                PDKClient.sharedInstance().createBoard(boardName, boardDescription: nil, withSuccess: { (response) in
                    sendPin(response.board())
                    }, andFailure: { (error) in
                        completion?(result: nil, error: error)
                })
            }
            
        }) { (error) in
            completion?(result: nil, error: error)
        }
    }
}