//
//  SelectProjectEntityDataContainer.swift
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 2/9/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

import UIKit

class SelectProjectEntityDataContainer: CellDataContainer {
    
    var fieldName : String
    var fieldValue : String?
    var displayName : String
    var entityType : ProjectEntityType?
    static let type = "selectProject"
    
    
    init(fieldName : String, fieldValue: String?, displayName: String, entityType : ProjectEntityType) {
        self.fieldName = fieldName
        self.fieldValue = fieldValue
        self.displayName = displayName
        self.entityType = entityType
    }
    
    convenience init(fieldName : String, displayName: String, entityType : ProjectEntityType) {
        self.init(fieldName: fieldName, fieldValue: "", displayName: displayName, entityType: entityType)
    }
}
