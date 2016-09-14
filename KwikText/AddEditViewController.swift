//
//  AddEditViewController.swift
//  KwikText
//
//  Created by Paul Barnes on 11/09/2016.
//  Copyright © 2016 PaulBa71. All rights reserved.
//

import UIKit
import ContactsUI

class AddEditViewController: UIViewController, CNContactPickerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var message: String = ""
    var name: String = ""
    var number: String = ""
    var index: Int = -1
    
    var phoneNumbers: [String] = []
    
    var contactStore = CNContactStore()

    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var contactImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageField.text=message
        nameField.text=name
        numberField.text=number
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if index == -1{
            navigationItem.title="Add item"
        } else {
            navigationItem.title="Edit item"
        }
        navigationItem.backBarButtonItem?.title="Back"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Respond to the choose from contacts button press. Display the contacts picker
    @IBAction func chooseFromContacts(_ sender: AnyObject) {
        let controller = CNContactPickerViewController()
        controller.delegate = self;
        controller.predicateForEnablingContact =
            NSPredicate(format:
                "phoneNumbers.@count > 0",
                        argumentArray: nil)
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var numberSelectionLabel: UILabel!
    @IBOutlet weak var numberSelectionTable: UITableView!

    
    // Called when the user has picked a contact
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        self.nameField.text = contact.givenName + " " + contact.familyName
        if let imageData = contact.imageData {
            self.contactImage.image = UIImage(data: imageData)
            self.contactImage.contentMode = UIViewContentMode.scaleAspectFit
        }
        if contact.phoneNumbers.count==1{
            self.numberField.text = contact.phoneNumbers[0].value.stringValue;
            
        }
        else{
            // Allow the user to pick one...
            phoneNumbers.removeAll()
            for num in contact.phoneNumbers{
                var line=num.value.stringValue;
                line += " ["
                line += num.label!
                line += "]"
                phoneNumbers.append(line)
            }
            numberSelectionLabel.isHidden=false
            numberSelectionTable.isHidden=false
            numberSelectionTable.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneNumbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NumbersCustomCell
        
        // Fill in the data
        cell.cellLabel.text=phoneNumbers[(indexPath as NSIndexPath).row]
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Choose the number and hide the table...
        numberSelectionLabel.isHidden=true
        numberSelectionTable.isHidden=true
    }
    
    func showMessage(text: String){
        let alertController = UIAlertController(title: "KwikText", message:
            text, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(text: message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindToMainView"{
            if let destVC=segue.destination as? ViewController {
                destVC.addMessage = messageField.text!
                destVC.addName = nameField.text!
                destVC.addNumber = numberField.text!
                destVC.addImage = contactImage.image!
            }
        }
    }
    

}
