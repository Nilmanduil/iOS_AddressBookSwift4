//
//  ContactsTableViewController.swift
//  AddressBookSwift4
//
//  Created by Thibault Goudouneix on 25/10/2017.
//  Copyright © 2017 Thibault Goudouneix. All rights reserved.
//

import UIKit
import CoreData

class ContactsTableViewController: UITableViewController {
    
    var persons : [Contact] = [Contact]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Mes Contacts"
        // Import names.plist
        let namesPlist = Bundle.main.path(forResource: "names", ofType: "plist")
        let url = URL(fileURLWithPath: (namesPlist)!)
        let dataArray = NSArray(contentsOf: url)
        print(dataArray ?? NSArray())
        
        /*for dict in dataArray! {
            if let dictionary = dict as? [String: String] {
                print(dictionary)
                let person = Contact(firstname: dictionary["name"]!, lastname: dictionary["lastname"]!)
                persons.append(person)
            }
        }
        
        persons.append(Contact(firstname: "Alan", lastname: "Turing"))
        persons.append(Contact(firstname: "Ada", lastname: "Lovelace"))
        persons.append(Contact(firstname: "Stephen", lastname: "Hawking"))
        persons.append(Contact(firstname: "Marie", lastname: "Curie"))*/
        
        
        /*let context = appDelegate().persistentContainer.viewContext
        let person = Contact(entity: Contact.entity(), insertInto: context)
        person.firstname = "Thibault"
        person.lastname = "Goudouneix"
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }*/
        reloadDataFromDatabase()
        
        let hasVisitedKey : String = "hasVisited"
        if let value = UserDefaults.standard.value(forKey: hasVisitedKey) {
            
        } else {
            let welcomeAlertController = UIAlertController(title: "Bienvenue", message: "Merci d'avoir lancé l'application", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            welcomeAlertController.addAction(okAction)
            self.present(welcomeAlertController, animated: true)
            UserDefaults.standard.set(true, forKey: hasVisitedKey)
        }

        // self.tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "ContactTableViewCell")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let addContact = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactPress))
        self.navigationItem.rightBarButtonItem = addContact
    }
    
    func reloadDataFromDatabase() {
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        let sortFirstname = NSSortDescriptor(key: "firstname", ascending: true)
        let sortLastname = NSSortDescriptor(key: "lastname", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstname, sortLastname]
        
        let context = self.appDelegate().persistentContainer.viewContext
        
        guard let contactsDB = try? context.fetch(fetchRequest) else { return }
        print(contactsDB)
        persons = contactsDB
        tableView.reloadData()
    }
    
    @objc func addContactPress() {
        // Create and push AddViewController
        let addContactVC : AddContactViewController = AddContactViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(addContactVC, animated: true)
        // Set the delegate
        addContactVC.delegate = self        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return persons.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    //*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath)

        // Configure the cell...
        if let contactCell = cell as? ContactTableViewCell {
            // contactCell.nameLabel.text = persons[indexPath.row].getFullName()
            contactCell.nameLabel.text = persons[indexPath.row].firstname! + " " + persons[indexPath.row].lastname!
        }

        return cell
    }
    //*/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = ContactDetailsViewController(nibName: nil, bundle: nil)
        controller.contact = self.persons[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

extension ContactsTableViewController : AddContactDelegate {
    func addContact(firstname: String, lastname: String) {
        let context = appDelegate().persistentContainer.viewContext
        let person = Contact(entity: Contact.entity(), insertInto: context)
        person.firstname = firstname
        person.lastname = lastname
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        //persons.append(Contact(firstname: firstname, lastname: lastname))
        self.navigationController?.popViewController(animated: true)
        //tableView.reloadData()
        reloadDataFromDatabase()
    }
}
