//
//  RNLeftAndRightHeaderFooterView.swift
//  Rubin
//
//  Created by Vladimir Goncharov on 12.03.15.
//  Copyright (c) 2015 Flatstack. All rights reserved.
//

import UIKit

class RNLeftAndRightHeaderFooterView: UITableViewHeaderFooterView
{
    @IBOutlet weak var leftLabelView: UILabel!
    @IBOutlet weak var rightLabelView: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.initialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialization()
    }
    
    internal func initialization() {
        self.prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.leftLabelView.text     = nil
        self.rightLabelView.text    = nil
    }
}
