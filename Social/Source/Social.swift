import UIKit

//MARK: - SocialNetwork protocol
public protocol SocialNetwork : NSObjectProtocol {
    static func name() -> String
    
    static func isAuthorized() -> Bool
    static func authorization(completion: ((success: Bool, error: NSError?) -> Void)?)
    static func logout()
}

extension SocialNetwork where Self: Equatable {}

public func == (lhs: SocialNetwork, rhs: SocialNetwork) -> Bool {
    return lhs.dynamicType.name() == rhs.dynamicType.name()
}



//MARK: - Abstract SocialOperation
public enum SocialOperationState {
    case Waiting
    case Sending
    case Successed
    case Failed
    case Cancelled
}

public typealias SocialOperationCompletionBlock        = (operation: SocialOperation, result: AnyObject?) -> Void
public typealias SocialOperationDidChangeStateBlock    = (operation: SocialOperation, newState: SocialOperationState) -> Void
public typealias SocialOperationFailureBlock           = (operation: SocialOperation, error: NSError?, isCancelled: Bool) -> Void

public class SocialOperation: NSOperation {
    
    private(set) public var state : SocialOperationState = .Waiting {
        didSet {
            social_performInMainThreadSync {[weak self] () -> Void in
                guard let sself = self else { return }
                sself.didChangeState?(operation: sself, newState: sself.state)
            }
        }
    }
    private(set) internal var result : AnyObject? = nil
    private(set) internal var error : NSError? = nil
    
    public let completion: SocialOperationCompletionBlock
    public let failure: SocialOperationFailureBlock
    public var didChangeState: SocialOperationDidChangeStateBlock?
    
    public init(completion: SocialOperationCompletionBlock, failure: SocialOperationFailureBlock) {
        
        self.completion = completion
        self.failure = failure
        
        super.init()
        
        if self.isMemberOfClass(SocialOperation.self) {
            fatalError("SocialOperation is abstract class")
        }
    }
    
    //MARK: - updating current state
    final func setSendingState() {
        let newState = SocialOperationState.Sending
        self.validateNewState(newState)
        
        self.state = newState
    }
    
    final func setSuccessedState(result: AnyObject?) {
        let newState = SocialOperationState.Successed
        self.validateNewState(newState)
        
        self.result = result
        self.state = newState
        
        social_performInMainThreadSync {[weak self] () -> Void in
            guard let sself = self else { return }
            sself.completion(operation: sself, result: result)
        }
    }
    
    final func setFailedState(error: NSError?) {
        
        let newState = SocialOperationState.Failed
        self.validateNewState(newState)
        
        self.error = error
        self.state = newState
        
        social_performInMainThreadSync {[weak self] () -> Void in
            guard let sself = self else { return }
            sself.failure(operation: sself, error: error, isCancelled: false)
        }
    }
    
    //MARK: - override
    override public func cancel() {
        let newState = SocialOperationState.Cancelled
        self.validateNewState(newState)
        
        self.state = newState
        
        social_performInMainThreadSync {[weak self] () -> Void in
            guard let sself = self else { return }
            sself.failure(operation: sself, error: nil, isCancelled: true)
        }
        
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


