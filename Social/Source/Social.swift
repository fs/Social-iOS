import UIKit



//MARK: - SocialNetwork protocol
protocol SocialNetwork : NSObjectProtocol {
    static func name() -> String
    
    static func isAuthorized() -> Bool
    static func authorization(completion: ((success: Bool, error: NSError?) -> Void)?)
    static func logout()
}

extension SocialNetwork where Self: Equatable {}

func == (lhs: SocialNetwork, rhs: SocialNetwork) -> Bool {
    return lhs.dynamicType.name() == rhs.dynamicType.name()
}



//MARK: - Abstract SocialOperation
enum SocialOperationState {
    case Waiting
    case Sending
    case Successed
    case Failed
    case Cancelled
}

typealias SocialOperationCompletionBlock = ((result: AnyObject?) -> Void)?
typealias SocialOperationDidChangeStateBlock = ((newState: SocialOperationState) -> Void)?
typealias SocialOperationFailureBlock = ((error: NSError?, isCancelled: Bool) -> Void)?

class SocialOperation: NSOperation {
    
    private(set) var state : SocialOperationState = .Waiting {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {[weak self] () -> Void in
                
                if let sself = self {
                    sself.didChangeState?(newState: sself.state)
                }
            }
        }
    }
    private(set) var result : AnyObject? = nil
    private(set) var error : NSError? = nil
    
    let completion: SocialOperationCompletionBlock
    let failure: SocialOperationFailureBlock
    var didChangeState: SocialOperationDidChangeStateBlock
    
    init(completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) {
        
        self.completion = completion
        self.failure = failure
        
        super.init()
        
        if self.isMemberOfClass(SocialOperation.self) {
            fatalError("SocialOperation is abstract class")
        }
    }
    
    //MARK: - updating current state
    internal final func setSendingState() {
        let newState = SocialOperationState.Sending
        self.validateNewState(newState)
        
        self.state = newState
    }
    
    internal final func setSuccessedState(result: AnyObject?) {
        let newState = SocialOperationState.Successed
        self.validateNewState(newState)
        
        self.state = newState
        self.result = result
        self.completion?(result: result)
    }
    
    internal final func setFailedState(error: NSError?) {
        
        if self.state == .Cancelled {
            return
        }
        
        let newState = SocialOperationState.Failed
        self.validateNewState(newState)
        
        self.state = newState
        self.error = error
        self.failure?(error: error, isCancelled: false)
    }
    
    //MARK: - override
    override func cancel() {
        let newState = SocialOperationState.Cancelled
        self.validateNewState(newState)
        
        self.state = newState
        self.failure?(error: nil, isCancelled: true)
        
        super.cancel()
    }
    
    //MARK: - private
    private func validateNewState(newState: SocialOperationState) {
        switch self.state {
        case let x where x == .Successed || x == .Failed || x == .Cancelled:
            fatalError("Repeated attempts to install state of \(self) operation with \(newState) when operation is \(x)")
            
        default:
            break
        }
    }
}


