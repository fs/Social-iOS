import UIKit

//MARK: - cells

//MARK: - DataCell
internal class DataCell: UITableViewCell {
    
    @IBOutlet weak var photoView:UIImageView!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var urlField: UITextField!
    
    var didChangeTextHandler:((textView: UITextView, string: String) -> Void)?
    var didChangeURLHandler:((textField: UITextField, string: String) -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoView?.image = nil
        self.messageTextField?.text = nil
        self.urlField?.text = nil
        
        self.didChangeTextHandler   = nil
        self.didChangeURLHandler    = nil
    }
}

extension DataCell: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var newtext:NSString    = textView.text as NSString
        newtext                 = newtext.stringByReplacingCharactersInRange(range, withString: text)
        
        if text == "\n" {
            textView.resignFirstResponder()
        }
        
        self.didChangeTextHandler?(textView: textView, string: newtext as String)
        
        return true
    }
}

extension DataCell: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newtext:NSString    = (textField.text ?? "") as NSString
        newtext                 = newtext.stringByReplacingCharactersInRange(range, withString: string)
        
        if textField == "\n" {
            textField.resignFirstResponder()
        }
        
        self.didChangeURLHandler?(textField: textField, string: newtext as String)
        
        return true
    }
}


//MARK: - PromptCell
internal class PromptCell: UITableViewCell {
    
    @IBOutlet weak var promptLabel: UILabel!
}


//MARK: - SocialNetworkCell
internal class SocialNetworkCell:UITableViewCell {
    
    @IBOutlet weak var socialNetworkLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.socialNetworkLabel?.text = nil
    }
}

//MARK: - SocialNetworkEnablingCell
internal class SocialNetworkEnablingCell: SocialNetworkCell {
    
    @IBOutlet weak var enabledSwitchView: UISwitch!
    
    var didTouchSwitchHandler:((on: Bool) -> Void)?
    
    @IBAction func changeStateSwitchView(sender: UISwitch) {
        self.didTouchSwitchHandler?(on: sender.on)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.enabledSwitchView?.on = false
        self.didTouchSwitchHandler = nil
    }
}

//MARK: - SocialNetworkConnectingCell
internal class SocialNetworkConnectingCell: SocialNetworkCell {
    
    var didTouchConnectHandler:(() -> Void)?
    
    @IBAction func connectSocialNetwork(sender: UIButton) {
        self.didTouchConnectHandler?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.didTouchConnectHandler = nil
    }
}

//MARK: - SocialNetworkUploading
internal class SocialNetworkUploading: SocialNetworkCell {
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.indicatorView.startAnimating()
    }
}

//MARK: - SocialNetworkText
internal class SocialNetworkText: SocialNetworkCell {
    
    @IBOutlet weak var socialNetworkDetailLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.socialNetworkDetailLabel?.text = nil
    }
}







//MARK: -
class SocialNetworkState: NSObject {

    var isNeedToSend = true
    weak var operationPostToWall: SocialOperation?
}

private var AssociatedSocialNetworkStateHandle: UInt8 = 0
extension SocialNetwork {
    
    var socialNetworkState: SocialNetworkState {
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedSocialNetworkStateHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            if let state = objc_getAssociatedObject(self, &AssociatedSocialNetworkStateHandle) as? SocialNetworkState {
                return state
            } else {
                let state = SocialNetworkState()
                self.socialNetworkState = state
                return state
            }
        }
    }
}




//MARK: -
internal final class Message {
    var text: String = "Some text"
    var image: UIImage?
    var url: String? = "http://www.adme.ru/narodnoe-tvorchestvo/kogda-koryavye-nadpisi-na-stenah-smotryat-pryamo-v-dushu-886410/?vksrc=vksrc886410"
}



//MARK :- ShareViewController

class ShareViewController: UIViewController {
    
    enum SectionsEnum: Int {
        case data                   = 0
        case socialNetworks         = 1
        case prompt                 = 2
    }
    
    //MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    //MARK: - share params
    let message = Message()
    
    //MARK: - private params
    private lazy var socialNetworks: [SocialNetwork] = { return [FacebookNetwork.shared, TwitterNetwork.shared, VKNetwork.shared, GoogleNetwork.shared] }()
    private var isDisplayZeroAccuntsError: Bool = false
    
    //MARK: - life cycle
    override func loadView() {
        super.loadView()
        self.tableView.registerNib(UINib(nibName: "RNLeftAndRightHeaderFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "RNLeftAndRightHeaderFooterView")
    }
    
    //MARK: - actions
    
    @IBAction func tappedInView(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func tappedInImageView(sender: AnyObject) {
        self.tryShowLybraryController(self)
    }
    
    @IBAction func longTappedInImageView(sender: AnyObject) {
        self.message.image = nil
        self.tableView.reloadData()
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        let includedSocialNetworks  = self.includedSocialNetworks()
        
        var countOfSocialNetwork    = includedSocialNetworks.count
        if countOfSocialNetwork > 0 {
            
            self.isDisplayZeroAccuntsError   = false
            
            let socialsSection          = SectionsEnum.socialNetworks.rawValue
            
            self.sendButton.enabled             = false
            self.sendButton.backgroundColor     = UIColor(red: 100/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1.0)
            
            #if swift(>=2.2)
            let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(ShareViewController.cancelSendingMessage(_:)))
            #else
            let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelSendingMessage:")
            #endif
            
            self.navigationItem.setRightBarButtonItem(item, animated: true)
            
            self.navigationItem.setHidesBackButton(true, animated: true)
            let completionHandler       = {[weak self]() -> Void in
                
                countOfSocialNetwork -= 1
                if countOfSocialNetwork == 0 {
                    if let sself = self {
                        sself.sendButton.enabled    = true
                        sself.navigationItem.setHidesBackButton(false, animated: true)
                        sself.navigationItem.setRightBarButtonItem(nil, animated: true)
                        
                        sself.sendButton.backgroundColor = UIColor(red: 187/255.0, green: 19/255.0, blue: 62/255.0, alpha: 1.0)

                        UIAlertView(title: "Yeaaaaah!", message: "All task has been completed", delegate: nil, cancelButtonTitle: "OK").show()
                    }
                }
            }
            
            for i in 0.stride(to: includedSocialNetworks.count, by: 1) {
                let network = includedSocialNetworks[i]
                
                let updateUI = {[weak self] (isFinished: Bool) -> Void in
                    
                    if let sself = self {
                        
                        if let index = sself.socialNetworks.indexOf({ (socialNetwork) -> Bool in
                            return socialNetwork == network }) {
                            sself.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: socialsSection)], withRowAnimation: UITableViewRowAnimation.Automatic)
                        }
                        
                        if let view = sself.tableView.headerViewForSection(socialsSection) as? RNLeftAndRightHeaderFooterView {
                            sself.updateHeaderFooterViewInSection(view, section:socialsSection)
                        }
                    }
                    
                    if isFinished == true {
                        completionHandler()
                    }
                }
                
                var url: NSURL? = nil
                if let messageURL = self.message.url {
                    url = NSURL(string: messageURL)
                }
                
                if let networkAsPostToWallAction = network as? PostToWallAction {
                    let operation = networkAsPostToWallAction.postDataToWall(self.message.text, image: self.message.image, url: url, completion: { (result) -> Void in
                        updateUI(true)
                        }, failure: { (operation, error, isCancelled) -> Void in
                            print(error)
                            updateUI(true)
                    })
                    operation.didChangeState = {(newState) -> Void in
                        updateUI(false)
                    }
                    network.socialNetworkState.operationPostToWall = operation
                } else {
                    print("\(network) doesn't support PostToWallAction protocol")
                    updateUI(true)
                }
            }
            
            self.tableView.reloadSections(NSIndexSet(index: socialsSection), withRowAnimation: UITableViewRowAnimation.Automatic)
        } else {
            self.isDisplayZeroAccuntsError = true
        }
        
        self.tableView.reloadSections(NSIndexSet(index: SectionsEnum.prompt.rawValue), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    @IBAction func cancelSendingMessage(sender: AnyObject) {
        let includedSocialNetworks  = self.includedSocialNetworks()
        for network in includedSocialNetworks {
            network.socialNetworkState.operationPostToWall?.cancel()
        }
    }
    
    //MARK: - lybrary presenter helper
    private func tryShowLybraryController(presentingViewController: UIViewController) {
        if let libraryController = self.libraryController() {
            presentingViewController.presentViewController(libraryController, animated: true, completion: nil)
        } else {
            UIAlertView(title: "\"Сохраненные фото\" не доступны", message: nil, delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    private func libraryController() -> UIImagePickerController? {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let newPickerController         = UIImagePickerController()
            newPickerController.sourceType  = UIImagePickerControllerSourceType.SavedPhotosAlbum
            newPickerController.delegate    = self
            
            return newPickerController
        }
        
        return nil
    }
    
    //MARK: - social helper
    private func includedSocialNetworks() -> [SocialNetwork] {
        var result: [SocialNetwork] = []
        for socialNetwork in self.socialNetworks {
            if socialNetwork.dynamicType.isAuthorized && socialNetwork.socialNetworkState.isNeedToSend {
                result.append(socialNetwork)
            }
        }
        return result
    }
    
    private func sentSocialNetworks() -> [SocialNetwork] {
        var result: [SocialNetwork] = []
        for socialNetwork in self.socialNetworks {
            if socialNetwork.socialNetworkState.operationPostToWall?.state == .Successed {
                result.append(socialNetwork)
            }
        }
        return result
    }
}

extension ShareViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    internal func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        self.dismissViewControllerAnimated(true, completion:{[weak self] () -> Void in
            
            if let sself = self {
                let photoImage  = info[UIImagePickerControllerOriginalImage] as! UIImage
                sself.message.image = photoImage
                
                sself.tableView.reloadData()
            }
        })
    }
}

extension ShareViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case SectionsEnum.data.rawValue, SectionsEnum.socialNetworks.rawValue:
            return 32
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case SectionsEnum.data.rawValue:    return 130
        default: return 44
        }
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case SectionsEnum.data.rawValue, SectionsEnum.socialNetworks.rawValue:
            
            let headerView          = tableView.dequeueReusableHeaderFooterViewWithIdentifier("RNLeftAndRightHeaderFooterView") as! RNLeftAndRightHeaderFooterView
            headerView.contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            
            let leftLabel           = headerView.leftLabelView
            leftLabel.textColor     = UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
            
            let rightLabel          = headerView.rightLabelView
            rightLabel.textColor    = UIColor(red: 29/255.0, green: 124/255.0, blue: 4/255.0, alpha: 1.0)
            
            self.updateHeaderFooterViewInSection(headerView, section: section)
            
            return headerView
            
        default:
            return nil
        }
    }
    
    private func updateHeaderFooterViewInSection(view: RNLeftAndRightHeaderFooterView, section: Int) {
        switch section {
        case SectionsEnum.data.rawValue, SectionsEnum.socialNetworks.rawValue:
            
            var leftText: String? = nil
            switch section
            {
            case SectionsEnum.data.rawValue:
                leftText    = "Что вы хотите показать другим болельщикам?"

            case SectionsEnum.socialNetworks.rawValue:
                leftText    = "Совет: больше сетей - больше шанс выиграть"
            default:
                return
            }
            
            let leftLabel           = view.leftLabelView
            leftLabel.text          = leftText
            
        default:
            return
        }
    }
}

extension ShareViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        switch indexPath.section
        {
        case SectionsEnum.socialNetworks.rawValue:
            if self.isAuthNetwork(indexPath.row) == true {
                return .Delete
            }
            return .None
            
        default:
            return .None
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section
        {
        case SectionsEnum.socialNetworks.rawValue:
            if self.isAuthNetwork(indexPath.row) == true {
                return true
            }
            return false
            
        default:
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section
        {
        case SectionsEnum.socialNetworks.rawValue:
            if self.isAuthNetwork(indexPath.row) == true {
                let socialNetwork = self.socialNetworks[indexPath.row]
                socialNetwork.dynamicType.logout(nil)
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
            }
            
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case SectionsEnum.data.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("DataCell") as! DataCell
            cell.photoView.image       = self.message.image
            cell.messageTextField.text = self.message.text
            cell.urlField.text         = self.message.url
            cell.didChangeTextHandler  = {[weak self](textView: UITextView, string: String) -> Void in
                
                if let sself = self {
                    let messageSection: Int = SectionsEnum.data.rawValue
                    
                    sself.message.text     = string
                    if let view = sself.tableView.headerViewForSection(messageSection) as? RNLeftAndRightHeaderFooterView {
                        sself.updateHeaderFooterViewInSection(view, section:messageSection)
                    }
                }
            }
            cell.didChangeURLHandler = {[weak self](textField: UITextField, string: String) -> Void in
                
                if let sself = self {
                    sself.message.url   = string
                }
            }
            return cell

        case SectionsEnum.socialNetworks.rawValue:
            let socialNetwork = self.socialNetworks[indexPath.row]
            if socialNetwork.dynamicType.isAuthorized == false {
                let cell = tableView.dequeueReusableCellWithIdentifier("SocialNetworkConnectingCell") as! SocialNetworkConnectingCell
                cell.socialNetworkLabel.text        = socialNetwork.dynamicType.name
                cell.didTouchConnectHandler         = { () -> Void in
                    
                    socialNetwork.dynamicType.authorization({[weak self] (success, error) in
                        if let sself = self where success == true {
                            if let indexPath = sself.tableView.indexPathForCell(cell) {
                                sself.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                            }
                        }
                    })
                }
                return cell
            } else {
                let name = socialNetwork.dynamicType.name
                if let state = socialNetwork.socialNetworkState.operationPostToWall?.state where state != .Waiting {
                    
                    switch state {
                    case .Sending:
                        let cell = tableView.dequeueReusableCellWithIdentifier("SocialNetworkUploading") as! SocialNetworkUploading
                        cell.socialNetworkLabel.text        = name
                        return cell
                        
                    default:
                        let cell = tableView.dequeueReusableCellWithIdentifier("SocialNetworkText") as! SocialNetworkText
                        cell.socialNetworkLabel.text        = name
                        switch state
                        {
                        case .Successed:
                            cell.socialNetworkDetailLabel.text = "Отправлено!"
                        case .Failed:
                            cell.socialNetworkDetailLabel.text = "Ошибка..."
                        case .Cancelled:
                            cell.socialNetworkDetailLabel.text = "Отменено"
                        default:
                            fatalError("\(state.hashValue) not implemented")
                        }
                        return cell
                    }
                    
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("SocialNetworkEnablingCell") as! SocialNetworkEnablingCell
                    cell.socialNetworkLabel.text        = name
                    cell.enabledSwitchView.on           = socialNetwork.socialNetworkState.isNeedToSend
                    cell.didTouchSwitchHandler          = {[weak self] (on: Bool) -> Void in
                        
                        if let sself = self {
                            let socialNetwork = sself.socialNetworks[indexPath.row]
                            socialNetwork.socialNetworkState.isNeedToSend  = on
                        }
                    }
                    return cell
                }
            }

        case SectionsEnum.prompt.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("PromptCell") as! PromptCell
                return cell
            
        default:
            fatalError("\(indexPath)")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionsEnum.data.rawValue: return 1
        case SectionsEnum.socialNetworks.rawValue: return self.socialNetworks.count
        case SectionsEnum.prompt.rawValue: return self.isExistPromtCell() ? 1 : 0
        default:
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        switch indexPath.section
        {
        case SectionsEnum.socialNetworks.rawValue:
            if self.isAuthNetwork(indexPath.row) == true {
                return "Выйти"
            }
            return nil
            
        default:
            return nil
        }
    }
    
    //MARK: - private
    private func isAuthNetwork(index: Int) -> Bool {
        let socialNetwork = self.socialNetworks[index]
        return socialNetwork.dynamicType.isAuthorized
    }
    
    private func isExistPromtCell() -> Bool {
        return self.isDisplayZeroAccuntsError
    }
}

