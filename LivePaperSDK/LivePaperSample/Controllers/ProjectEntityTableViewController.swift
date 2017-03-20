//
//  LinksTableViewController.swift
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/26/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

import UIKit
import LivePaperSDK
import SVProgressHUD

protocol ProjectEntityTableViewControllerDelegate {
    func didSelectEntity(controller: ProjectEntityTableViewController, entity:LPProjectEntity)
}

enum ProjectEntityType{
    case link
    case trigger
    case payoff
}

class ProjectEntityTableViewController: BaseTableViewController, EntityDetailsTableViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var project : LPProject?
    var session : LPSession?
    var entityArray : [LPProjectEntity]?
    var selectedEntity : LPProjectEntity?
    var selectedPayoffType : LPPayoffType?
    var selectedTriggerType : LPTriggerType?
    var controllerMode = ProjectEntityControllerMode.crud
    var delegate : ProjectEntityTableViewControllerDelegate?
    var projectEntityType : ProjectEntityType!
    
    enum EntityFields {
        static let name = "name"
        static let url = "url"
        static let triggerId = "triggerId"
        static let payoffId = "payoffId"
    }
    
    enum ProjectEntityControllerMode{
        case crud
        case selection
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.controllerMode == .crud {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addEntity(button:)))
        }
        reloadEntities()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private methods
    
    func pluralEntityName() -> String {
        return entityName() + "s"
    }
    
    func entityName() -> String {
        switch self.projectEntityType! {
        case .link:
            return "Link"
        case .payoff:
            return "Payoff"
        case .trigger:
            return "Trigger"
        }
    }
    
    func reloadEntities(){
        SVProgressHUD.show()
        switch self.controllerMode {
        case .crud:
            self.title = self.pluralEntityName()
        case .selection:
            self.title = "Select \(self.entityName())"
        }
        
        switch self.projectEntityType! {
        case .link:
            LPLink.list(self.project?.session, projectId: self.project?.identifier, completion: { (links, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    self.displayError(error: error)
                    return
                }
                self.entityArray = links
                self.tableView.reloadData()
            })
        case .trigger:
            LPTrigger.list((self.project?.session)!, projectId: (self.project?.identifier)!, completion: { (triggers, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    self.displayError(error: error)
                    return
                }
                self.entityArray = triggers
                self.tableView.reloadData()
            })
        case .payoff:
            LPPayoff.list(self.project?.session, projectId: self.project?.identifier, completion: { (payoffs, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    self.displayError(error: error)
                    return
                }
                self.entityArray = payoffs
                self.tableView.reloadData()
            })
        }
    }
    
    func fieldForLinks(link : LPLink?) -> [CellDataContainer] {
        return [
            TextCellDataContainer(fieldName: EntityFields.name, fieldValue: link?.name ?? "", displayName: "Name"),
            SelectProjectEntityDataContainer(fieldName: EntityFields.triggerId, fieldValue: link?.triggerId ?? "", displayName: "Trigger Id", entityType: .trigger),
            SelectProjectEntityDataContainer(fieldName: EntityFields.payoffId, fieldValue: link?.payoffId ?? "", displayName: "Payoff Id", entityType: .payoff)
        ]
    }
    
    func fieldForTriggers(trigger : LPTrigger?) -> [CellDataContainer] {
        return [
            TextCellDataContainer(fieldName: EntityFields.name, fieldValue: trigger?.name ?? "", displayName: "Name")
        ]
    }
    
    func fieldForPayoffs(payoff: LPPayoff? ,payoffType : LPPayoffType) -> [CellDataContainer] {
        switch payoffType {
        case .url:
            return [
                TextCellDataContainer(fieldName: EntityFields.name, fieldValue: payoff?.name ?? "", displayName: "Name"),
                TextCellDataContainer(fieldName: EntityFields.url, fieldValue: payoff?.url.absoluteString ?? "", displayName: "URL")
            ]
        case .rich:
            return [
                TextCellDataContainer(fieldName: EntityFields.name, fieldValue: payoff?.name ?? "", displayName: "Name"),
                TextCellDataContainer(fieldName: EntityFields.url, fieldValue: payoff?.richPayoffPublicUrl.absoluteString ?? "", displayName: "Public URL")
            ]
        default:
            return []
        }
    }
    
    func addEntity(button: UIBarButtonItem){
        switch self.projectEntityType! {
        case .link:
            self.presentDetails(detailsType: .create, cellDataArray: self.fieldForLinks(link:nil))
        case .trigger:
            let alertController = UIAlertController.init(title: "Type", message: "Select One", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction.init(title: "Short URL", style: .default, handler: { (action : UIAlertAction) in
                self.selectedTriggerType = LPTriggerType.shortUrl
                self.presentDetails(detailsType: .create, cellDataArray: self.fieldForTriggers(trigger: nil))
            }))
            alertController.addAction(UIAlertAction.init(title: "QR Code", style: .default, handler: { (action : UIAlertAction) in
                self.selectedTriggerType = LPTriggerType.qrCode
                self.presentDetails(detailsType: .create, cellDataArray: self.fieldForTriggers(trigger: nil))
            }))
            alertController.addAction(UIAlertAction.init(title: "Watermark", style: .default, handler: { (action : UIAlertAction) in
                self.selectedTriggerType = LPTriggerType.watermark
                self.presentDetails(detailsType: .create, cellDataArray: self.fieldForTriggers(trigger: nil))
            }))
            self.present(alertController, animated: true, completion: nil)
        case .payoff:
            let alertController = UIAlertController.init(title: "Type", message: "Select One", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction.init(title: "Web", style: .default, handler: { (action : UIAlertAction) in
                self.selectedPayoffType = LPPayoffType.url
                self.presentDetails(detailsType: .create, cellDataArray: self.fieldForPayoffs(payoff: nil, payoffType: .url))
            }))
            alertController.addAction(UIAlertAction.init(title: "Rich", style: .default, handler: { (action : UIAlertAction) in
                self.selectedPayoffType = LPPayoffType.rich
                self.presentDetails(detailsType: .create, cellDataArray: self.fieldForPayoffs(payoff: nil, payoffType: .rich))
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentDetails(detailsType : EditEntityTableViewController.DetailsType, cellDataArray : [CellDataContainer]){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "editProject") as!UINavigationController
        let vc = controller.viewControllers.first as! EditEntityTableViewController
        vc.delegate = self
        vc.detailsType = detailsType
        vc.session = self.session
        vc.project = self.project
        switch detailsType {
        case .create:
            vc.title = "Create " + self.entityName()
        case .edit:
            vc.title = "Edit "  + self.entityName()
        }
        vc.cellDataArray = cellDataArray
        self.present(controller, animated: true, completion: nil)
    }
    
    override func editEntityAtIndexPath(indexPath : IndexPath) {
        let entity = self.entityArray![indexPath.row]
        self.selectedEntity = entity
        
        var cellDataArray : [CellDataContainer]?
        if let _ = entity as? LPLink {
            cellDataArray = self.fieldForLinks(link:entity as? LPLink)
        }else if let _ = entity as? LPTrigger {
            cellDataArray = self.fieldForTriggers(trigger: entity as? LPTrigger)
        }else if let payoff = entity as? LPPayoff {
            switch payoff.type {
            case .url:
                cellDataArray = self.fieldForPayoffs(payoff: entity as? LPPayoff, payoffType: .url)
            case .rich:
                cellDataArray = self.fieldForPayoffs(payoff: entity as? LPPayoff, payoffType: .rich)
            default:
                cellDataArray = []
            }
        }
        if let cellDataArray = cellDataArray {
            self.presentDetails(detailsType: .edit, cellDataArray: cellDataArray)
        }
    }
    
    override func deleteEntityAtIndexPath(indexPath : IndexPath) {
        let entity = self.entityArray![indexPath.row]
        SVProgressHUD.show()
        entity.delete { (error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.displayError(error: error)
            }else{
                self.entityArray?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func extractDataFromCellDataArray(fieldName: String, cellDataArray : [CellDataContainer]) -> String {
        for cellData in cellDataArray {
            if let textData = cellData as? TextCellDataContainer, cellData.fieldName == fieldName {
                return textData.fieldValue ?? ""
            }
            if let selectEntityData = cellData as? SelectProjectEntityDataContainer, cellData.fieldName == fieldName {
                return selectEntityData.fieldValue ?? ""
            }
        }
        return ""
    }
    
    func getRichPayoffData() -> [String : Any] {
        return [
            "type" : "content action layout",
            "version" : "1",
            "data" : [
                "content" : [
//                    "type" : "image",
//                    "label" : "Link Technology",
//                    "data" : [
//                        "URL" : "https://stegasis.linkcreationstudio.com/assets/link-technology-logo-3f44cdd57ffd56d494137c1275fccc7d8e667bcd9e77546510f35ea9fd764607.png"
//                    ]
                    "type" : "video",
                    "label" : "Link Technology",
                    "data" : [
                        "URL" : "http://www.dropbox.com/s/30ankfpzrfsqiqn/funny_cats_1_512kb.mp4?dl=1",
                        "imageURL": "http://www.thefunniestfaces.com/wp-content/uploads/2010/10/93d7ae34-6695-4750-ac39-2964253aadc71.jpg",
                        "fullscreen": false
                    ]
                ],
                "actions" : [
                    [
                    "type" : "webpage",
                    "label" : "123456789 abcdefghijklmnopqrstuvwxyz 123456789 123456789 1234567",
                    "icon" : [ "id" : "536" ],
                    "data" : [ "URL" : "https://mylinks.linkcreationstudio.com/developer" ]
                    ],
                    [
                        "type" : "webpage",
                        "label" : "123456789 abcdefghijklmnopqrstuvwxyz 123456789 123456789 1234567",
                        "icon" : [ "id" : "536" ],
                        "data" : [ "URL" : "https://mylinks.linkcreationstudio.com/developer" ]
                    ],
                    [
                        "type" : "webpage",
                        "label" : "123456789 abcdefghijklmnopqrstuvwxyz 123456789 123456789 1234567",
                        "icon" : [ "id" : "536" ],
                        "data" : [ "URL" : "https://mylinks.linkcreationstudio.com/developer" ]
                    ],
                    [
                        "type" : "webpage",
                        "label" : "123456789 abcdefghijklmnopqrstuvwxyz 123456789 123456789 1234567",
                        "icon" : [ "id" : "536" ],
                        "data" : [ "URL" : "https://mylinks.linkcreationstudio.com/developer" ]
                    ],
                    [
                        "type" : "webpage",
                        "label" : "123456789 abcdefghijklmnopqrstuvwxyz 123456789 123456789 1234567",
                        "icon" : [ "id" : "536" ],
                        "data" : [ "URL" : "https://mylinks.linkcreationstudio.com/developer" ]
                    ],
                    [
                    "type" : "share",
                    "label" : "Share",
                    "icon" : [ "id" : "527" ],
                    "data" : [ "URL" : "Take a look at this site: https://mylinks.linkcreationstudio.com" ]
                    ]
                ]
            ]
        ]
    }
    
    func dismissDetailsController(controller : UIViewController, error: Error?){
        SVProgressHUD.dismiss()
        controller.dismiss(animated: true, completion: {
            if let error = error {
                self.displayError(error: error)
                return
            }
            self.reloadEntities()
        })
    }
    
    func didFinishEditingPayoff(name: String, controller:EditEntityTableViewController, cellDataArray: [CellDataContainer], detailsType: EditEntityTableViewController.DetailsType) {
        let urlString = extractDataFromCellDataArray(fieldName: EntityFields.url, cellDataArray: cellDataArray)
        let url = URL(string: urlString)
        let richPayoff = getRichPayoffData()
        
        switch detailsType {
        case .create:
            let completionBlock = { (payoff : LPPayoff?, error : Error?) in
                self.dismissDetailsController(controller: controller, error: error)
            }
            switch self.selectedPayoffType! {
            case .url:
                LPPayoff.createWebPayoff(withName: name, url: url, projectId: self.project?.identifier, session: self.session!, completion:completionBlock)
            case .rich:
                LPPayoff.createRichPayoff(withName: name, publicURL: url, richPayoffData: richPayoff, projectId: self.project?.identifier, session: self.session!, completion: completionBlock)
            case .custom:
                break
            }
        case .edit:
            if let payoff = self.selectedEntity as? LPPayoff {
                payoff.name = name
                switch payoff.type {
                case .url:
                    payoff.url = url
                case .rich:
                    payoff.richPayoffPublicUrl = url
                    payoff.richPayoffData = richPayoff
                case .custom:
                    break
                }
                payoff.update({ (error) in
                    self.dismissDetailsController(controller: controller, error: error)
                })
            }
        }
    }
    
    func didFinishEditingTrigger(name: String, controller:EditEntityTableViewController, cellDataArray: [CellDataContainer], detailsType: EditEntityTableViewController.DetailsType) {
        
        switch detailsType {
        case .create:
            let completionBlock = { (trigger : LPTrigger?, error : Error?) in
                self.dismissDetailsController(controller: controller, error: error)
            }
            switch self.selectedTriggerType! {
            case .shortUrl:
                LPTrigger.createShortUrl(withName: name, projectId: (self.project?.identifier)!, session: self.session!, completion: completionBlock)
            case .qrCode:
                LPTrigger.createQrCode(withName: name, projectId: (self.project?.identifier)!, session: self.session!, completion: completionBlock)
            case .watermark:
                LPTrigger.createWatermark(withName: name, projectId: (self.project?.identifier)!, session: self.session!, completion: completionBlock)
            }
        case .edit:
            self.selectedEntity?.name = name
            self.selectedEntity?.update({ (error) in
                self.dismissDetailsController(controller: controller, error: error)
            })
        }
    }
    
    func didFinishEditingLink(name: String, controller:EditEntityTableViewController, cellDataArray: [CellDataContainer], detailsType: EditEntityTableViewController.DetailsType) {
        
        switch detailsType {
        case .create:
            let triggerId = extractDataFromCellDataArray(fieldName: EntityFields.triggerId, cellDataArray: cellDataArray)
            let payoffId = extractDataFromCellDataArray(fieldName: EntityFields.payoffId, cellDataArray: cellDataArray)
            LPLink.create(withName: name, triggerId: triggerId, payoffId: payoffId, projectId: self.project?.identifier, session: self.session, completion: { (link, error) in
                self.dismissDetailsController(controller: controller, error: error)
            })
        case .edit:
            self.selectedEntity?.name = name
            self.selectedEntity?.update({ (error) in
                self.dismissDetailsController(controller: controller, error: error)
            })
        }
    }
    
    func createWatemarkedImage(trigger : LPTrigger){
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func createQrCode(trigger : LPTrigger){
        SVProgressHUD.showProgress(0)
        trigger.getQrCodeImage(progress: { (progress) in
            SVProgressHUD.showProgress(Float(progress))
        }) { (image, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.displayError(error: error)
                return
            }
            if let image = image {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        var title : String?
        var message : String?
        if let _ = error {
            title = "Error"
            message = "Could not save image to photo gallery. Please make sure you give the app permission to access your photo gallery"
        } else {
            title = "Image Saved"
            message = "The image was saved in your photo gallery"
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entityArray?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        let entity = entityArray?[indexPath.row]
        cell.textLabel?.text = entity?.name;
        if let payoff = entity as? LPPayoff {
            switch payoff.type {
            case .url:
                cell.detailTextLabel?.text = "Url payoff"
            case .rich:
                cell.detailTextLabel?.text = "Rich payoff"
            case .custom:
                cell.detailTextLabel?.text = "Custom payoff"
            }
        }else if let payoff = entity as? LPTrigger {
            switch payoff.type {
            case .shortUrl:
                cell.detailTextLabel?.text = "Short URL trigger"
            case .qrCode:
                cell.detailTextLabel?.text = "QR code trigger"
            case .watermark:
                cell.detailTextLabel?.text = "Watermark trigger"
            }
        }else{
            cell.detailTextLabel?.text = ""
        }
        cell.selectionStyle = .none
        return cell
    }
    
    // Mark : UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.controllerMode {
        case .crud:
            let alertController = UIAlertController.init(title: "Select Action", message: "Pick an action to perform on this resource", preferredStyle: .actionSheet)
            if let trigger = entityArray?[indexPath.row] as? LPTrigger {
                self.selectedEntity = trigger
                switch trigger.type {
                case .watermark:
                    alertController.addAction(UIAlertAction.init(title: "Watermark image", style: .default, handler: { (action : UIAlertAction) in
                        self.createWatemarkedImage(trigger: trigger)
                    }))
                case .qrCode:
                    alertController.addAction(UIAlertAction.init(title: "Create QR code", style: .default, handler: { (action : UIAlertAction) in
                        self.createQrCode(trigger: trigger)
                    }))
                default:
                    break
                }
            }
            alertController.addAction(UIAlertAction.init(title: "Edit", style: .default, handler: { (action : UIAlertAction) in
                self.editEntityAtIndexPath(indexPath: indexPath)
            }))
            alertController.addAction(UIAlertAction.init(title: "Delete", style: .destructive, handler: { (action : UIAlertAction) in
                self.deleteEntityAtIndexPath(indexPath: indexPath)
            }))
            alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        case .selection:
            let entity = self.entityArray![indexPath.row]
            SVProgressHUD.dismiss()
            delegate?.didSelectEntity(controller: self, entity: entity)            
        }
    }
    
    // Mark: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) { 
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
                SVProgressHUD.showProgress(0)
                if let trigger = self.selectedEntity as? LPTrigger {
                    let imageData = UIImageJPEGRepresentation(image, 0.95)
                    trigger.getWatermarkForImageData(imageData!, progress: { (progress) in
                        SVProgressHUD.showProgress(Float(progress))
                    }, completion: { (image, error) in
                        SVProgressHUD.dismiss()
                        if let error = error {
                            self.displayError(error: error)
                            return
                        }
                        if let image = image {
                            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
                        }
                    })
                }
            }else{
                let alertController = UIAlertController(title: "Error", message: "No image was picked", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            let alertController = UIAlertController(title: "Error", message: "No image was picked", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    
    // Mark: EntityDetailsTableViewController
    
    func didFinishEditing(controller:EditEntityTableViewController, cellDataArray: [CellDataContainer], detailsType: EditEntityTableViewController.DetailsType) {
        
        SVProgressHUD.show()
        let name = extractDataFromCellDataArray(fieldName: EntityFields.name, cellDataArray: cellDataArray)
        
        switch self.projectEntityType! {
        case .payoff:
            self.didFinishEditingPayoff(name: name, controller: controller, cellDataArray: cellDataArray, detailsType: detailsType)
        case .trigger:
            self.didFinishEditingTrigger(name: name, controller: controller, cellDataArray: cellDataArray, detailsType: detailsType)
        case .link:
            self.didFinishEditingLink(name: name, controller: controller, cellDataArray: cellDataArray, detailsType: detailsType)
        }
        
    }

}
