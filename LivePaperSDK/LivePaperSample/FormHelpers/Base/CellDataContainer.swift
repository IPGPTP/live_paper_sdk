//
//  CellDataContainer.swift
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/26/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

import UIKit

protocol CellDataContainer {
    
    var fieldName: String { get set }
    var displayName: String { get set }
    static var type: String { get }

}
