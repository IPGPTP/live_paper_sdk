//
//  SelectProjectEntityTableViewController.swift
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/27/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

import UIKit
import LivePaperSDK

class SelectProjectEntityTableViewController: UITableViewController {
    
    var project : LPProject?
    var session : LPSession?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProjectEntityTableViewController, let identifier = segue.identifier {
            switch identifier {
            case "links":
                vc.projectEntityType = .link
            case "triggers":
                vc.projectEntityType = .trigger
            case "payoffs":
                vc.projectEntityType = .payoff
            default: break
            }
            vc.project = self.project
            vc.session = self.session;
        }
        
    }
    
}
