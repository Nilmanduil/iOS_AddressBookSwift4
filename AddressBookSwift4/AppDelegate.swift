//
//  AppDelegate.swift
//  AddressBookSwift4
//
//  Created by Thibault Goudouneix on 25/10/2017.
//  Copyright © 2017 Thibault Goudouneix. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AddressBookSwift4")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getDataFromServer() {
        let url = URL(string: "http://10.1.0.242:3000/persons")!
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error: \(error.localizedDescription)")
                }
                return
            }
            let jsonObject = data!
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async {
                    print("Server Error")
                }
                return
            }
            
            if let string = String (data: jsonObject, encoding: .utf8) {
                DispatchQueue.main.async {
                    let dictionary = try? JSONSerialization.jsonObject(with: jsonObject, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    guard let jsonDict = dictionary as? [[String : Any]] else {
                        return
                    }
                    
                    self.updateFromJsonData(json: jsonDict)
                }
            }
        }
        task.resume()
    }
    
    func downloadResource(url: URL) -> Data? {
        var finish: Bool = false, success: Bool = false
        var dlData: Data? = nil
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error: \(error.localizedDescription)")
                }
                finish = true
                success = false
                return
            }
            dlData = data!
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async {
                    print("Server Error")
                }
                finish = true
                success = false
                return
            }
            success = true
            finish = true
        }
        task.resume()
        while(!finish) {
            // Do nothing
        }
        if success {
            return dlData
        } else {
            return nil
        }
    }
    
    func updateFromJsonData(json: [[String : Any]]) {
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        let sortFirstname = NSSortDescriptor(key: "firstname", ascending: true)
        let sortLastname = NSSortDescriptor(key: "lastname", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstname, sortLastname]
        
        let context = self.persistentContainer.viewContext
        
        let contacts = try! context.fetch(fetchRequest)
        let contactIds = contacts.map({ (contact) -> Int32 in
            return contact.id
        })
        
        let serverIds = json.map({ (dict) -> Int in
            return dict["id"] as? Int ?? 0
        })
        
        // Delete data that is not on server
        for contact in contacts {
            if !serverIds.contains(Int(contact.id)) {
                context.delete(contact)
            }
        }
        
        // Update or create
        for contactDict in json {
            let id = contactDict["id"] as? Int ?? 0
            if let index = contactIds.index(of: Int32(id)) {
                contacts[index].firstname = contactDict["surname"] as? String ?? "ERROR"
                contacts[index].lastname = contactDict["lastname"] as? String ?? "ERROR"
                contacts[index].avatarUrl = contactDict["pictureUrl"] as? String ?? ""
            } else {
                let contact = Contact(context: context)
                contact.id = Int32(id)
                contact.firstname = contactDict["surname"] as? String
                contact.lastname = contactDict["lastname"] as? String
                contact.avatarUrl = contactDict["pictureUrl"] as? String
            }
            
            do {
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                print(error)
            }
            
            /* let contact = Contact(entity: Contact.entity(), insertInto: context)
            contact.id = contactDict["id"] as? Int32 ?? 0
            contact.firstname = contactDict["surname"] as? String ?? "DefaultName"
            contact.lastname = contactDict["lastname"] as? String ?? "DefaultName"
            contact.avatarUrl = contactDict["pictureUrl"] as? String ?? "" */
        }
    }
    
    func sendContactToServer(contact: Contact) {
        var dictionary = [String : Any]()
        dictionary["surname"] = contact.firstname
        dictionary["lastname"] = contact.lastname
        dictionary["pictureUrl"] = "https://robohash.org/" + contact.firstname! + contact.lastname!
        let contactJson = try? JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.sortedKeys)
        // print(contactJson)
        var urlRequest = URLRequest(url: URL(string: "http://10.1.0.242:3000/persons")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.uploadTask(with: urlRequest, from: contactJson) { data, response, error in
            print("Post sent")
            if let error = error {
                print(error)
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 201 else {
                print("Some error happened")
                return
            }
            if response.mimeType == "text/plain" || response.mimeType == "text/plain",
                let data = data {
                print(data)
            }
            let dictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            guard let dict = dictionary as? [String : Any] else {
                return
                
            }
            let id = dict["id"] as? Int32 ?? 0
            contact.id = id
            /*print("Data : ")
            print(String(describing: dictionary))
            print("Response : ")
            print(response)*/
        }
        task.resume()
    }
    
    func deleteContactOnServer(contact: Contact) {
        var urlRequest = URLRequest(url: URL(string: "http://10.1.0.242:3000/persons/" + String(contact.id))!)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error: \(error.localizedDescription)")
                }
                return
            }
            let jsonObject = data!
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async {
                    print("Server Error")
                }
                return
            }
            
            if let string = String (data: jsonObject, encoding: .utf8) {
                
            }
        }
        task.resume()
    }
}

extension UIViewController {
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
