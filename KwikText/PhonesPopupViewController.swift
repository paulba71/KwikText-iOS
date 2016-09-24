//
//  PhonesPopupViewController.swift
//  KwikText
//
//  Created by Paul Barnes on 14/09/2016.
//  Copyright © 2016 PaulBa71. All rights reserved.
//

import UIKit

class PhonesPopupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var phoneNumbers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional init
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of rows called")
        return phoneNumbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("get cell called")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NumbersCustomCell
        cell.cellLabel.text = phoneNumbers[indexPath.row]
        return cell;
    }
}
