//
//  AboutViewController.swift
//  KwikText
//
//  Created by Paul Barnes on 16/09/2016.
//  Copyright © 2016 PaulBa71. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Choose the right label font size for the screen size
        if UIScreen.main.bounds.size.height == 480 {
            // iPhone 4
            label.font = label.font.withSize(15)
            
        } else if UIScreen.main.bounds.size.height == 568 {
            // IPhone 5
            label.font = label.font.withSize(15)
            
        } else if UIScreen.main.bounds.size.width == 375 {
            // iPhone 6
            label.font = label.font.withSize(20)
            
        } else if UIScreen.main.bounds.size.width == 414 {
            // iPhone 6+
            label.font = label.font.withSize(20)
            
        } else if UIScreen.main.bounds.size.width == 768 {
            // iPad
            label.font = label.font.withSize(20)
            
        }
    }

    @IBOutlet weak var label: UILabel!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendFeedback(_ sender: AnyObject) {
        sendEmail()
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate=self
            mail.setToRecipients(["paulba71@hotmail.com"])
            mail.setSubject("Feedback on KwikText for iPhone")
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        print("Mail should have been sent")
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
