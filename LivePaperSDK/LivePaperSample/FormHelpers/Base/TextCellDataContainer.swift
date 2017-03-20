//
//  TextCellDataContainer.swift
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 2/9/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

import UIKit

class TextCellDataContainer: CellDataContainer {
    
    var fieldName : String
    var fieldValue : String?
    var displayName : String
    static let type = "textCell"
    
    init(fieldName : String, fieldValue: String?, displayName: String) {
        self.fieldName = fieldName
        self.fieldValue = fieldValue
        self.displayName = displayName
    }
    
    convenience init(fieldName : String, displayName: String) {
        self.init(fieldName: fieldName, fieldValue: "", displayName: displayName)
    }
}
