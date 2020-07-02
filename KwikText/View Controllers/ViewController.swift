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
    let imagesKey="Images"
    
    let appSettings=UserDefaults.standard;
    
    // Variables to hold the results of the add / edit view
    var addMessage=""
    var addName=""
    var addNumber=""
    var addImage: UIImage = UIImage(named:"person")!
    var addSelectedItem = -1
    
    var selectedItem = -1
    
    func LoadDefaults()
    {
        templatesCount=9
        
        messages=["On my way",
                    "Stuck in traffic",
                      "Leaving in five",
                      "In a meeting - call you when done",
                      "Give me a buzz when you get a chance",
                      "Everything ok?",
                      "Running late",
                      "Give you a shout in a bit",
                      "Home in 5. Flick on the kettle"
        ]
        
        targets = ["Choose from contacts",
                   "Choose from contacts",
                       "Choose from contacts",
                       "Choose from contacts",
                       "Choose from contacts",
                       "Choose from contacts",
                       "Choose from contacts",
                       "Choose from contacts",
                       "Choose from contacts"
        ]
        
        
        phoneNumbers = ["",
                        "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            ""
        ]
    }
    
    func initImages()
    {
        images = [UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person"),
                  UIImage(named:"person")
        ]

    }
    
    // Functions to load and save the image arrays
    
    // Save an individual file...
    func saveImageDocumentDirectory(image: UIImage, index: Int){
        let fileName="Image" + String(index) + ".jpg"
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fileName)
        print("Saving - " + paths)
        let imageData = image.jpegData(compressionQuality: 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getImage(index: Int) -> UIImage{
        let fileManager = FileManager.default
        let fileName="Image" + String(index) + ".jpg"
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: imagePAth){
            print("Loading - " + imagePAth)
            return UIImage(contentsOfFile: imagePAth)!
        }else{
            print("No Image")
            return UIImage(named:"person")!;
        }
    }
    
    func createDirectory(){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("customDirectory")
        if !fileManager.fileExists(atPath: paths){
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        }else{
            print("Already dictionary created.")
        }
    }
    
    func deleteDirectory(){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("customDirectory")
        if fileManager.fileExists(atPath: paths){
            try! fileManager.removeItem(atPath: paths)
        }else{
            print("Something wrong.")
        }
    }
    
    func saveImages() -> Bool {
        do {
            var index=0
            deleteDirectory()   // Remove all old images
            createDirectory()   // Create the new dir
            for image in images {
                saveImageDocumentDirectory(image: image!, index: index)
                index += 1;
            }
            return true
        }
    }
    
    func loadImages() -> Bool {
        do {
            images.removeAll()
            var index = 0
            while index < phoneNumbers.count {
                let image=getImage(index: index)
                images.append(image)
                index+=1
            }
            return true
        }
    }
    
    
    func LoadTemplatesFromSettings(){
        let count = appSettings.integer(forKey: templatesCountKey)
        
        if count != 0{
            // If we have a count load the settings
            templatesCount = count
            
            messages=appSettings.object(forKey: messagesKey) as? [String] ?? [String]()
            targets=appSettings.object(forKey: targetsKey) as? [String] ?? [String]()
            phoneNumbers=appSettings.object(forKey: numbersKey) as? [String] ?? [String]()
            if loadImages() == false{
                print("Failed to load images")
            }
            if images.count != phoneNumbers.count{
                initImages()
            }
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
        } else {
            // prompt for a number
            let alert = UIAlertController(title: "No number stored", message: "Please enter a number to send to", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Send", style: UIAlertAction.Style.default, handler: nil))
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter number:"
                textField.keyboardType = UIKeyboardType.phonePad
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func sendHandler (message: String, number: String)
    {
        let messageVC=MFMessageComposeViewController()
        messageVC.messageComposeDelegate=self
        messageVC.body=message
        messageVC.recipients=[number]
        self.present(messageVC, animated: true, completion: nil)
    }
    
    func SaveTemplatesToSettings(){
        appSettings.set(targets.count, forKey: templatesCountKey)
        appSettings.set(messages, forKey: messagesKey)
        appSettings.set(phoneNumbers, forKey: numbersKey)
        appSettings.set(targets, forKey: targetsKey)
        //appSettings.set(images, forKey: imagesKey)  // images wont work... need to save to document storage
        if saveImages() == false{
            print("Images failed to save")
        }
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
        if indexPath.row >= images.count {
            cell.photo.image = UIImage(named:"person") // Fallback in the case of not loading the image files
        } else {
            cell.photo.image=images[(indexPath as NSIndexPath).row]
        }
        cell.photo.image=images[(indexPath as NSIndexPath).row]
        cell.messageLabel.text=messages[(indexPath as NSIndexPath).row]
        cell.targetLabel.text=targets[(indexPath as NSIndexPath).row]
        return cell;
    }
    
    // Handle the delete and edit swipe mode...
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
        
        let myAction2=UITableViewRowAction(style: .normal, title: "Edit", handler: {
            // closure parameters passed in by the system // Closure is just an anonomous method
            action, indexPath in
            
            // do the edit...
            self.selectedItem=indexPath.row
            self.performSegue(withIdentifier: "showAddEditSegue", sender: self)
            
            // save to disk
            self.SaveTemplatesToSettings()
            
            // refresh
            tableView.reloadData();
            
            // tell the table view it's done editing
            tableView.isEditing=false
            
        })
        
        let actions=[myAction,myAction2]
        return actions

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("message send")
        DoMessageSend(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedItem = 	-1;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddEditSegue"{
            if let destVC=segue.destination as? AddEditViewController {
                addSelectedItem = selectedItem // Need to preserve this state to handle a back button press also.
                if(selectedItem == -1)
                {
                    destVC.mode = AddEditViewController.ModeType.ModeAdd
                    destVC.message = ""
                    destVC.name = ""
                    destVC.number = ""
                    destVC.image = UIImage(named:"person")!
                    destVC.index = -1
                } else {
                    destVC.mode = AddEditViewController.ModeType.ModeEdit
                    destVC.index = selectedItem
                    destVC.name = targets[selectedItem]
                    destVC.number = phoneNumbers[selectedItem]
                    destVC.message = messages[selectedItem]
                    destVC.image=images[selectedItem]!
                }
            }
        }
        
        if(segue.identifier == "showEditSegue"){
            print("Edit segue")
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
    
    @IBAction func addButtonClick(_ sender: AnyObject) {
        print("add clicked")
        selectedItem = -1
        if(tableView.numberOfRows(inSection: 0) < maxTemplates)
        {
            self.performSegue(withIdentifier: "showAddEditSegue", sender: tableView)
        }
        else{
            // tell the user that the number of
        }
    }
    
    
    @IBAction func unwindToMainView(unwindSegue: UIStoryboardSegue) {
        print(unwindSegue.identifier)
        // Edit the items...
        if selectedItem == -1{
            // Add mode
            messages.append(addMessage)
            targets.append(addName)
            phoneNumbers.append(addNumber)
            images.append(addImage)
            SaveTemplatesToSettings()
            tableView.reloadData()
            
        } else {
            // TODO - Edit mode selectedItem
            messages[selectedItem]=addMessage
            targets[selectedItem]=addName
            phoneNumbers[selectedItem]=addNumber
            images[selectedItem]=addImage
            selectedItem = -1
            SaveTemplatesToSettings()
            tableView.reloadData()
        }
    }
    
    

}

