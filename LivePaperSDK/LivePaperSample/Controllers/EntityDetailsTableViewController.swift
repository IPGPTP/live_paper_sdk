//
//  EditEntityTableViewController.swift
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/26/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

import UIKit
import LivePaperSDK

protocol EntityDetailsTableViewControllerDelegate {
    func didFinishEditing(controller: EditEntityTableViewController, cellDataArray : [CellDataContainer], detailsType: EditEntityTableViewController.DetailsType)
}

class EditEntityTableViewController: UITableViewController, TextFieldTableViewCellDelegate, ProjectEntityTableViewControllerDelegate {
    
    enum DetailsType{
        case create
        case edit
    }
    
    var session : LPSession?
    var project : LPProject?
    var cellDataArray : [CellDataContainer]!
    var delegate : EntityDetailsTableViewControllerDelegate?
    var detailsType : DetailsType!
    var currentEntitySelectionDataContainer : SelectProjectEntityDataContainer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName: "TextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: TextCellDataContainer.type)
        self.tableView.register(UINib.init(nibName: "SelectProjectEntityCell", bundle: nil), forCellReuseIdentifier: SelectProjectEntityDataContainer.type)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Mark: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProjectEntityTableViewController, let identifier = segue.identifier, identifier == "showEntity" {
            vc.project = self.project
            vc.session = self.session;
            vc.controllerMode = .selection
            if (self.currentEntitySelectionDataContainer?.fieldName == ProjectEntityTableViewController.EntityFields.triggerId){
                vc.projectEntityType = .trigger
            }else{
                vc.projectEntityType = .payoff
            }
            vc.delegate = self
        }        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = cellDataArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of:cellData).type, for: indexPath)
        if let textCellData = cellData as? TextCellDataContainer {
            let textCell = cell as! TextFieldTableViewCell
            textCell.fieldLabel?.text = textCellData.displayName
            textCell.fieldValue?.text = textCellData.fieldValue
            textCell.fieldName = cellData.fieldName
            textCell.delegate = self
        }else if let selectEntityData = cellData as? SelectProjectEntityDataContainer {
            let selectEntityCell = cell as! SelectProjectEntityCell
            selectEntityCell.textLabel?.text = selectEntityData.displayName
            selectEntityCell.detailTextLabel?.text = selectEntityData.fieldValue
        }
        return cell
    }
    
    // Mark: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = cellDataArray[indexPath.row]
        if let selectEntityData = cellData as? SelectProjectEntityDataContainer {
            self.currentEntitySelectionDataContainer = selectEntityData
            tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "showEntity", sender: self)
        }
    }
    
    // Mark: Internal methods
    
    @IBAction func doneButtonPressed() {
        self.delegate?.didFinishEditing(controller:self, cellDataArray: self.cellDataArray!, detailsType:detailsType)
    }
    
    @IBAction func closeButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Mark: ProjectEntityTableViewControllerDelegate
    
    func didSelectEntity(controller: ProjectEntityTableViewController, entity: LPProjectEntity) {
        self.currentEntitySelectionDataContainer?.fieldValue = entity.identifier
        self.tableView.reloadData()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // Mark: TextFieldTableViewCellDelegate
    
    func fieldChanged(name: String, value: String) {
        for cellData in cellDataArray! {
            if let textCellData = cellData as? TextCellDataContainer, cellData.fieldName == name {
                textCellData.fieldValue = value
            }
        }
    }
 
}
