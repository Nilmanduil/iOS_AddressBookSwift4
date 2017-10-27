//
//  ContactDetailsViewController.swift
//  AddressBookSwift4
//
//  Created by Thibault Goudouneix on 25/10/2017.
//  Copyright © 2017 Thibault Goudouneix. All rights reserved.
//

import UIKit

class ContactDetailsViewController: UIViewController {
    
    var contact : Contact! = nil
    weak var deleteDelegate : DeleteContactDelegate?

    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    
    var avatar: UIImage? = nil
    
    @IBAction func didPressDelete(_ sender: Any) {
        let alertController : UIAlertController = UIAlertController(title: "Suppression du contact", message: "Voulez-vous vraiment supprimer " + contact.getFullName() + " ?", preferredStyle: UIAlertControllerStyle.alert)
        let confirmAction = UIAlertAction(title: "SUPPRIMER", style: UIAlertActionStyle.destructive, handler: {
            alert -> Void in
            
            print("Suppression")
            self.deleteDelegate?.deleteContact(contact: self.contact)
        })
        let cancelAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.cancel, handler: {
            alert -> Void in
            
            print("Annulation suppression")
            
        })
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = contact.getFullName()
        let imageData = appDelegate().downloadResource(url: URL(string: contact.avatarUrl!)!)
        avatar = UIImage(data: imageData!)
        avatarView.image = avatar
        
        
        firstnameLabel.text = contact.firstname
        lastnameLabel.text = contact.lastname
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

protocol DeleteContactDelegate: AnyObject {
    func deleteContact(contact: Contact) -> Void
}
