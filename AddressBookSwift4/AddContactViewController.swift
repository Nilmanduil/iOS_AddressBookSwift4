//
//  AddContactViewController.swift
//  AddressBookSwift4
//
//  Created by Thibault Goudouneix on 25/10/2017.
//  Copyright © 2017 Thibault Goudouneix. All rights reserved.
//

import UIKit

class AddContactViewController: UIViewController {
    
    weak var delegate : AddContactDelegate?

    @IBOutlet weak var nameField: UITextField!
    
    @IBAction func didPressAdd(_ sender: Any) {
        if let text =  nameField.text {
            self.delegate?.addContact(name: text)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Nouveau contact"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

protocol AddContactDelegate: AnyObject {
    func addContact(name: String) -> Void
}
