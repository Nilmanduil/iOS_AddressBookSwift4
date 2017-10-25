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

    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    
    @IBOutlet weak var additionProgressView: UIProgressView!
    var progress: Float = 0
    
    @IBAction func didPressAdd(_ sender: Any) {
        if let firstname =  firstnameField.text, let lastname = lastnameField.text {
            additionProgressView.progress = 0.0
            additionProgressView.alpha = 1
            DispatchQueue.global(qos: .userInitiated).async {
                while self.progress < 1 {
                    Thread.sleep(forTimeInterval: 0.01)
                    self.progress += 0.01
                    
                    DispatchQueue.main.async {
                        self.additionProgressView.progress = self.progress
                    }
                }
                
                DispatchQueue.main.async {
                    self.delegate?.addContact(firstname: firstname, lastname: lastname)
                }
            }
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
    func addContact(firstname: String, lastname: String) -> Void
}
