//
//  ViewController.swift
//  KwikText
//
//  Created by Paul Barnes on 03/09/2016.
//  Copyright © 2016 PaulBa71. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var banner: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [String] = []
    
    var targets: [String] = []
    
    let maxTemplates=20
    
    var images = [UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person")
    ]
    
    var phoneNumbers: [String] = []
    
    let templatesCountKey="TemplatesCount"
    var templatesCount=0;   // Number of templates
    
    let messagesKey="MessageText"
    let targetsKey="TargetText"
    let numbersKey="NumberText"
    
    let appSettings=UserDefaults.standard;
    
    // Variables to hold the results of the add / edit view
    var addMessage=""
    var addName=""
    var addNumber=""
    var addImage: UIImage = UIImage(named:"person")!
    
    var selectedItem = -1
    
    func LoadDefaults()
    {
        templatesCount=9
        
        messages=["Test the app",
                    "On my way",
                      "Leaving in five",
                      "In a meeting - call you when done",
                      "Give me a buzz when you get a chance",
                      "Everything ok?",
                      "Running late",
                      "Give you a shout in a bit",
                      "Test the app"
        ]
        
        targets = ["Paul Barnes",
                   "Sharon Mobile",
                       "Choose from contacts",
                       "Paul Barnes",
                       "Choose from contacts",
                       "Choose from contacts",
                       "Choose from contacts",
                       "Choose from contacts",
                       "Paul Barnes"
        ]
        
        
        phoneNumbers = ["0879398817",
                        "0879912226",
                            "",
                            "0879398817",
                            "",
                            "",
                            "",
                            "",
                            "0879398817"
        ]
    }
    
    func LoadTemplatesFromSettings(){
        let count = appSettings.integer(forKey: templatesCountKey)
        
        if count != 0{
            // If we have a count load the settings
            templatesCount = count
            
            messages=appSettings.object(forKey: messagesKey) as? [String] ?? [String]()
            targets=appSettings.object(forKey: targetsKey) as? [String] ?? [String]()
            phoneNumbers=appSettings.object(forKey: numbersKey) as? [String] ?? [String]()
        } else {
            // First time out - save settings so they are here next time.
            LoadDefaults()
            SaveTemplatesToSettings()
        }
        
        // Here we want to replace the stock icon with the picture from the contact card...
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        // Dismiss the controller...
        controller.dismiss(animated: true, completion: nil)
    }
    
    func DoMessageSend(_ item: Int){
        // If there is no number ask for one...
        if item < phoneNumbers.count && !phoneNumbers[item].isEmpty {
            let messageVC=MFMessageComposeViewController()
            messageVC.messageComposeDelegate=self
            messageVC.body=messages[item]
            messageVC.recipients=[phoneNumbers[item]]
            self.present(messageVC, animated: true, completion: nil)
            
            
        }
    }
    
    func SaveTemplatesToSettings(){
        appSettings.set(targets.count, forKey: templatesCountKey)
        appSettings.set(messages, forKey: messagesKey)
        appSettings.set(phoneNumbers, forKey: numbersKey)
        appSettings.set(targets, forKey: targetsKey)
        appSettings.synchronize()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Load the settings from the user settings.
        LoadTemplatesFromSettings()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "MainIcon")
        imageView.image = image

        //navigationItem.titleView = imageView
        navigationItem.title="KwikText"
        navigationItem.backBarButtonItem?.title="Back"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fill in the actual data here
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        
        // Fill in the data
        
        cell.photo.image=images[(indexPath as NSIndexPath).row]
        cell.messageLabel.text=messages[(indexPath as NSIndexPath).row]
        cell.targetLabel.text=targets[(indexPath as NSIndexPath).row]
        return cell;
    }
    
    // Handle the delete swipe mode...
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let myAction=UITableViewRowAction(style: .default, title: "Delete", handler: {
            // closure parameters passed in by the system // Closure is just an anonomous method
            action, indexPath in
            
            // delete the row...
            self.messages.remove(at: (indexPath as NSIndexPath).row)
            self.targets.remove(at: (indexPath as NSIndexPath).row)
            self.phoneNumbers.remove(at: (indexPath as NSIndexPath).row)
            self.images.remove(at: (indexPath as NSIndexPath).row)
            
            // save to disk
            self.SaveTemplatesToSettings()
            
            // refresh
            tableView.reloadData();
            
            // tell the table view it's done editing
            tableView.isEditing=false
            
        })
        
        let actions=[myAction]
        return actions

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("message send")
        DoMessageSend(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddEditSegue"{
            if let destVC=segue.destination as? AddEditViewController {
                destVC.message = ""
                destVC.name = ""
                destVC.number = ""
                destVC.index = -1
            }
        }
    }

    @IBAction func reset(_ sender: AnyObject) {

        let confirm = UIAlertController(title: "Are you sure?", message: "Really reset the list?", preferredStyle: .alert)
        
        let yesAction=UIAlertAction(title: "Yes", style: .destructive, handler: {
            action in
            
            self.LoadDefaults()
            self.SaveTemplatesToSettings()
            self.tableView.reloadData()
        })
        
        let noAction=UIAlertAction(title: "No!", style: .default, handler: {
            action in
            print("That was a close one!")
        })
        
        
        // add the actions to the alert controller
        confirm.addAction(yesAction)
        confirm.addAction(noAction)
        
        // Show it
        present(confirm,animated: true, completion: nil)
        
        }
    
    @IBAction func unwindToMainView(unwindSegue: UIStoryboardSegue) {
        // Edit the items...
        if selectedItem == -1{
            // Add mode
            messages.append(addMessage)
            targets.append(addName)
            phoneNumbers.append(addNumber)
            // Handle the image next
            SaveTemplatesToSettings()
            tableView.reloadData()
            
        } else {
            // TODO - Edit mode
        }
    }

}

