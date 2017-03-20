//
//  ProjectsTableViewController.swift
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/26/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

import UIKit
import LivePaperSDK
import SVProgressHUD

class ProjectsTableViewController: BaseTableViewController, EntityDetailsTableViewControllerDelegate {
    
    var projects : [LPProject]?
    let LPP_CLIENT_ID = "CLIENT_ID_HERE"
    let LPP_CLIENT_SECRET = "CLIENT_SECRET_HERE"
    var session : LPSession!
    var selectedProject : LPProject?

    override func viewDidLoad() {
        super.viewDidLoad()
        session = LPSession.createSession(withClientId: LPP_CLIENT_ID, secret: LPP_CLIENT_SECRET)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProject(button:)))
        reloadProjects()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Mark: TableViewDatasource

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects?.count ?? 0;
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        cell.textLabel?.text = projects?[indexPath.row].name;
        cell.accessoryType = .disclosureIndicator        
        return cell
    }
    
    // Mark: Private methods
    
    func addProject(button: UIBarButtonItem){
        let cellDataArray = [
            TextCellDataContainer(fieldName: "name", fieldValue: "", displayName: "Name")
        ]
        self.presentDetails(detailsType: .create, cellDataArray: cellDataArray)
    }
    
    func reloadProjects(){
        SVProgressHUD.show()
        LPProject.list(session) { ( projects : [LPProject]?, error : Error?) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.displayError(error: error)
                return
            }
            self.projects = projects
            self.tableView.reloadData()
        }
    }
    
    func presentDetails(detailsType : EditEntityTableViewController.DetailsType, cellDataArray : [CellDataContainer]){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "editProject") as!UINavigationController
        let vc = controller.viewControllers.first as! EditEntityTableViewController
        vc.delegate = self
        vc.detailsType = detailsType
        switch detailsType {
        case .create:
            vc.title = "Create Project"
        case .edit:
            vc.title = "Edit Project"
        }
        vc.cellDataArray = cellDataArray
        self.present(controller, animated: true, completion: nil)
    }
    
    override func editEntityAtIndexPath(indexPath : IndexPath) {
        let project = self.projects![indexPath.row]
        self.selectedProject = project
        let cellDataArray = [
            TextCellDataContainer(fieldName: "name", fieldValue: project.name, displayName: "Name")
        ]
        self.presentDetails(detailsType: .edit, cellDataArray: cellDataArray)
    }
    
    override func deleteEntityAtIndexPath(indexPath : IndexPath) {
        let project = self.projects![indexPath.row]
        SVProgressHUD.show()
        project.delete({ (error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.displayError(error: error)
            }else{
                self.projects?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? SelectProjectEntityTableViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let project = projects?[indexPath.row]
            destination.project = project
            destination.title = project?.name
            destination.session = self.session
        }
    }
    
    // Mark: EntityDetailsTableViewController

    func didFinishEditing(controller:EditEntityTableViewController, cellDataArray: [CellDataContainer], detailsType: EditEntityTableViewController.DetailsType) {
        var name = ""
        for cellData in cellDataArray {
            if let textData = cellData as? TextCellDataContainer, cellData.fieldName == "name" {
                name = textData.fieldValue ?? ""
            }
        }
        SVProgressHUD.show()
        switch detailsType {
        case .create:
            LPProject.create(withName: name, session: self.session) { (project, error) in
                controller.dismiss(animated: true, completion: {
                    if let error = error {
                        self.displayError(error: error)
                    }
                    self.reloadProjects()
                })
            }
            break
        case .edit:
            self.selectedProject?.name = name
            self.selectedProject?.update({ (error) in
                controller.dismiss(animated: true, completion: {
                    if let error = error {
                        self.displayError(error: error)
                    }
                    self.reloadProjects()
                })
            })
        }
    }
}
