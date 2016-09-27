//
//  AddEditViewController.swift
//  KwikText
//
//  Created by Paul Barnes on 11/09/2016.
//  Copyright © 2016 PaulBa71. All rights reserved.
//

import UIKit
import ContactsUI

class AddEditViewController: UIViewController, CNContactPickerDelegate, UIPopoverPresentationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var message: String = ""
    var name: String = ""
    var number: String = ""
    var index: Int = -1
    var image: UIImage=UIImage(named:"person")!
    
    enum ModeType {
        case ModeAdd
        case ModeEdit
        case ModeClone
    }
    
    var mode=ModeType.ModeAdd
    
    var phoneNumbers: [String] = []
    
    var numberChoices: [String] = []
    
    var contactStore = CNContactStore()

    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var contactImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if(mode != ModeType.ModeAdd)
        {
            messageField.text=message
            nameField.text=name
            numberField.text=number
            contactImage.image=image
        }
        else{
            messageField.text=""
            nameField.text=""
            numberField.text=""
            contactImage.image=UIImage(named:"person")!	
        }
        // Setup a touch recogniser for the image
        let singleTap=UITapGestureRecognizer(target: self, action: Selector("tapDetected"))
        singleTap.numberOfTapsRequired=1
        contactImage.isUserInteractionEnabled=true
        contactImage.addGestureRecognizer(singleTap)
        
    }
    

    func tapDetected(){
         // open the contacts...
        print("Tap on image")
        pickerView.isHidden=true
        pickerLabel.isHidden=true
        
        let controller = CNContactPickerViewController()
        controller.delegate = self;
        controller.predicateForEnablingContact =
            NSPredicate(format:
                "phoneNumbers.@count > 0",
                        argumentArray: nil)
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if index == -1{
            navigationItem.title="Add item"
        } else {
            navigationItem.title="Edit item"
        }
        navigationItem.backBarButtonItem?.title="Back"
        //addChildViewController(PhonesPopupViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Respond to the choose from contacts button press. Display the contacts picker
    @IBAction func chooseFromContacts(_ sender: AnyObject) {
        pickerView.isHidden=true
        pickerLabel.isHidden=true
        
        let controller = CNContactPickerViewController()
        controller.delegate = self;
        controller.predicateForEnablingContact =
            NSPredicate(format:
                "phoneNumbers.@count > 0",
                        argumentArray: nil)
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    
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
                var label=num.label
                label=label?.replacingOccurrences(of: "_$!<", with: "")
                label=label?.replacingOccurrences(of: ">!$_", with: "")
                line += label!
                line += "]"
                
                phoneNumbers.append(line)
            }
            numberChoices=phoneNumbers
            // Show the picker view
            pickerView.isHidden=false
            pickerLabel.isHidden=false
            pickerView.reloadAllComponents()
        }
    }
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerLabel: UILabel!
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numberChoices[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Set the text
        let item=numberChoices[row]
        let index=item.range(of: "[", options: .backwards)
        let newItem=item.substring(to: (index?.lowerBound)!)
        numberField.text=newItem
        // Hide the picker
        pickerView.isHidden=true
        pickerLabel.isHidden=true
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
        
        if segue.identifier == "showPhonesPopup"
        {
            let vc=segue.destination as! PhonesPopupViewController
            let controller = vc.popoverPresentationController
            if controller != nil {
                controller!.delegate=self
            }
            print("prepare showPhonesPopup")
            vc.phoneNumbers=phoneNumbers

        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none;
    }
    

}
