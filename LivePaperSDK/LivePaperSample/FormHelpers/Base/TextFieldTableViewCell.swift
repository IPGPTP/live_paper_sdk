//
//  TextFieldTableViewCell.swift
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/26/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

import UIKit

protocol TextFieldTableViewCellDelegate {
    func fieldChanged(name: String, value: String)
}


class TextFieldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fieldLabel : UILabel?
    @IBOutlet weak var fieldValue : UITextField?
    var fieldName : String!
    var delegate : TextFieldTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        fieldValue?.addTarget(self, action: #selector(fieldValueChanged(field:)), for: .editingChanged)
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    deinit {
        fieldValue?.removeTarget(self, action: #selector(fieldValueChanged(field:)), for: .editingChanged)
    }
    
    // MARK: Private methods
    func fieldValueChanged(field : UITextField) {
        if let value = self.fieldValue?.text {
            delegate?.fieldChanged(name: self.fieldName, value: value)
        }
    }
    
}
