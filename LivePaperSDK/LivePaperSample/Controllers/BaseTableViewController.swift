//
//  BaseTableViewController.swift
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/27/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

    func displayError(error: Error?) {
        var message = "Unknown error"
        if let error = error as NSError? {
            message = error.localizedDescription
        }
        let alert = UIAlertController(title:"LivePaperSample", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MArk: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action : UITableViewRowAction, indexPath : IndexPath) in
            self.deleteEntityAtIndexPath(indexPath: indexPath)
        }
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action: UITableViewRowAction, indexPath) in
            tableView.setEditing(false, animated: true)
            self.editEntityAtIndexPath(indexPath: indexPath)
        }
        return [delete, edit];
    }
    
    // Mark: Abstract methods
    
    func editEntityAtIndexPath(indexPath : IndexPath) { }
    
    func deleteEntityAtIndexPath(indexPath : IndexPath) { }

}
