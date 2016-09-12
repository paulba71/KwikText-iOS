//
//  AddEditViewController.swift
//  KwikText
//
//  Created by Paul Barnes on 11/09/2016.
//  Copyright © 2016 PaulBa71. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class AddEditViewController: UIViewController, CNContactPickerDelegate {
    
    var message: String = ""
    var name: String = ""
    var number: String = ""
    var index: Int = -1
    
    var contactStore = CNContactStore()

    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageField.text=message
        nameField.text=name
        numberField.text=number
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseFromContacts(_ sender: AnyObject) {
        let controller = CNContactPickerViewController()
        controller.delegate = self;
        controller.predicateForEnablingContact =
            NSPredicate(format:
                "phoneNumbers.@count > 0",
                        argumentArray: nil)
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        self.nameField.text = contact.givenName + " " + contact.familyName
        if contact.phoneNumbers.count==1{
            self.numberField.text = contact.phoneNumbers[0].value.stringValue;
        }
        else{
            // Allow the user to pick one...
        }
        
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
